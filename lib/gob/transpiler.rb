# frozen_string_literal: true

require "syntax_tree"
require "syntax_tree/go"
require_relative "matcher"

module Gob
  class Transpiler
    include SyntaxTree::Go::DSL

    attr_reader :matcher, :source

    def initialize(matcher: nil)
      @matcher = matcher || Gob.default_matcher
      @scopes = [Set.new]
      @package_depth = 0
      @class_stack = []
    end

    def with_class_self(class_name)
      @class_stack.push(class_name)
      yield
    ensure
      @class_stack.pop
    end

    def current_class
      @class_stack.last
    end

    def contains_yield?(node)
      return false unless node
      return node.any? { |n| contains_yield?(n) } if node.is_a?(Array)
      if defined?(SyntaxTree::YieldNode) && node.is_a?(SyntaxTree::YieldNode)
        return true
      end
      return false unless node.respond_to?(:child_nodes)
      node.child_nodes.compact.any? { |n| contains_yield?(n) }
    rescue StandardError
      false
    end

    def transpile(source)
      @source = source
      @scopes = [Set.new]
      @class_stack = []
      program = SyntaxTree.parse(source)
      visit(program)
    end

    def visit(node)
      return nil if node.nil?
      return node.map { |n| visit(n) }.compact.flatten if node.is_a?(Array)

      result = matcher.match(node, self)
      return nil if result == Matcher::DROP
      return result unless result == Matcher::MISS

      raise UnsupportedNode,
            "No rule matched #{node.class}: #{node.inspect[0, 200]}"
    end

    def visit_all(nodes)
      Array(nodes).flat_map do |n|
        result = visit(n)
        case result
        when nil
          []
        when Array
          result
        else
          [result]
        end
      end
    end

    def param_name_list(node)
      params = node
      params = params.contents if params.is_a?(SyntaxTree::Paren)
      return [] unless params.is_a?(SyntaxTree::Params)

      (params.requireds || []).map do |p|
        p.is_a?(SyntaxTree::Ident) ? p.value : p.to_s
      end
    end

    def visit_params(node)
      param_name_list(node).map do |name|
        SyntaxTree::Go::Field.new(names: [Ident(name)], type: Ident("any"))
      end
    end

    def visit_args(node)
      return [] if node.nil?

      args_node = node
      args_node = args_node.arguments if args_node.is_a?(SyntaxTree::ArgParen)
      args_node = args_node.contents if args_node.is_a?(SyntaxTree::Paren)
      parts =
        args_node.is_a?(SyntaxTree::Args) ? args_node.parts : Array(args_node)
      visited = visit_all(parts)

      # Collapse trailing keyword args into a single map[any]any{} literal
      if visited.any? { |v| v.is_a?(SyntaxTree::Go::KeyValueExpr) }
        kwargs = []
        while visited.last.is_a?(SyntaxTree::Go::KeyValueExpr)
          kwargs.unshift(visited.pop)
        end
        if !kwargs.empty?
          visited << SyntaxTree::Go::CompositeLit.new(
            type:
              SyntaxTree::Go::MapType.new(
                map: nil,
                key: Ident("any"),
                value: Ident("any")
              ),
            lbrace: nil,
            elts: kwargs,
            rbrace: nil,
            incomplete: false
          )
        end
      end
      visited
    end

    def stmt_body(node)
      case node
      when SyntaxTree::BodyStmt
        stmt_body(node.statements)
      when SyntaxTree::Statements
        node.body
      when nil
        []
      else
        Array(node)
      end
    end

    def stmtify(node)
      return node if node.nil?

      case node
      when SyntaxTree::Go::DeclStmt, SyntaxTree::Go::ExprStmt,
           SyntaxTree::Go::AssignStmt, SyntaxTree::Go::ReturnStmt,
           SyntaxTree::Go::IfStmt, SyntaxTree::Go::ForStmt,
           SyntaxTree::Go::RangeStmt, SyntaxTree::Go::SwitchStmt,
           SyntaxTree::Go::SelectStmt, SyntaxTree::Go::BlockStmt,
           SyntaxTree::Go::BranchStmt, SyntaxTree::Go::DeferStmt,
           SyntaxTree::Go::GoStmt, SyntaxTree::Go::SendStmt,
           SyntaxTree::Go::IncDecStmt, SyntaxTree::Go::LabeledStmt,
           SyntaxTree::Go::EmptyStmt, SyntaxTree::Go::TypeSwitchStmt,
           SyntaxTree::Go::CaseClause, SyntaxTree::Go::CommClause,
           SyntaxTree::Go::BadStmt
        node
      when SyntaxTree::Go::GenDecl
        SyntaxTree::Go::DeclStmt.new(decl: node)
      else
        if node.class.name.include?("Expr") ||
             node.is_a?(SyntaxTree::Go::Ident) ||
             node.is_a?(SyntaxTree::Go::BasicLit)
          SyntaxTree::Go::ExprStmt.new(x: node)
        else
          node
        end
      end
    end

    def merge_if_init(stmts)
      out = []
      i = 0
      while i < stmts.length
        s = stmts[i]
        n = stmts[i + 1]
        if n.is_a?(SyntaxTree::Go::IfStmt) && n.init.nil?
          # merge preceding assign/decl-assign into if init when simple err pattern
          if s.is_a?(SyntaxTree::Go::AssignStmt) && s.lhs.length == 1 &&
               s.lhs.first.is_a?(SyntaxTree::Go::Ident)
            name = s.lhs.first.name
            if cond_uses_ident?(n.cond, name)
              out << SyntaxTree::Go::IfStmt.new(
                if_: nil,
                init: s,
                cond: n.cond,
                body: n.body,
                else_: n.else_
              )
              i += 2
              next
            end
          elsif s.is_a?(SyntaxTree::Go::DeclStmt) &&
                s.decl.is_a?(SyntaxTree::Go::GenDecl) &&
                s.decl.tok.to_s == "var" && s.decl.specs.length == 1
            spec = s.decl.specs.first
            if spec.names.length == 1 && spec.values && !spec.values.empty?
              name = spec.names.first.name
              asn =
                SyntaxTree::Go::AssignStmt.new(
                  lhs: [Ident(name)],
                  tok: ":=",
                  rhs: spec.values
                )
              if cond_uses_ident?(n.cond, name)
                out << SyntaxTree::Go::IfStmt.new(
                  if_: nil,
                  init: asn,
                  cond: n.cond,
                  body: n.body,
                  else_: n.else_
                )
                i += 2
                next
              end
            end
          end
        end
        out << s
        i += 1
      end
      out
    end

    def cond_uses_ident?(node, name)
      return false unless node
      case node
      when SyntaxTree::Go::Ident
        node.name == name
      when SyntaxTree::Go::BinaryExpr
        cond_uses_ident?(node.x, name) || cond_uses_ident?(node.y, name)
      when SyntaxTree::Go::UnaryExpr
        cond_uses_ident?(node.x, name)
      when SyntaxTree::Go::ParenExpr
        cond_uses_ident?(node.x, name)
      when SyntaxTree::Go::CallExpr
        cond_uses_ident?(node.fun, name) ||
          Array(node.args).any? { |a| cond_uses_ident?(a, name) }
      else
        false
      end
    end

    def scoped(names = [])
      @scopes.push(Set.new(names))
      yield
    ensure
      @scopes.pop
    end

    def declare(name)
      return unless name.is_a?(String) && name.match?(/\A[\w]+\z/)

      @scopes.last << name
    end

    def declared?(name)
      @scopes.any? { |s| s.include?(name) }
    end

    def declared_in_current_scope?(name)
      @scopes.last.include?(name)
    end

    def current_scope
      @scopes.last
    end

    def package_scope?
      @scopes.length <= 1
    end

    def string_value(node)
      case node
      when SyntaxTree::StringLiteral
        node
          .parts
          .map { |p| p.is_a?(SyntaxTree::TStringContent) ? p.value : "" }
          .join
      else
        nil
      end
    end

    def const_name(node)
      case node
      when SyntaxTree::ConstRef
        node.constant.value
      when SyntaxTree::ConstPathRef
        left = const_name(node.parent)
        right = node.constant.value
        left ? "#{left}::#{right}" : right
      when SyntaxTree::Const
        node.value
      when SyntaxTree::VarRef
        node.value.value
      else
        nil
      end
    end

    def signature_for_def(node)
      sig = nil
      # inline comments attached anywhere on the def node
      collect_comments(node).each do |c|
        s = parse_signature_comment(c.value)
        sig = s if s
      end
      # above-line comment
      if !sig && node.location && @source
        prev_line = node.location.start_line - 2
        if prev_line >= 0
          line = @source.lines[prev_line].to_s
          s = parse_signature_comment(line)
          sig = s if s
        end
      end
      sig
    end

    def collect_comments(node, out = [])
      return out unless node
      out.concat(node.comments) if node.respond_to?(:comments) && node.comments
      if node.respond_to?(:deconstruct_keys)
        node
          .deconstruct_keys(nil)
          .each_value do |v|
            case v
            when SyntaxTree::Node
              collect_comments(v, out)
            when Array
              v.each do |x|
                collect_comments(x, out) if x.is_a?(SyntaxTree::Node)
              end
            end
          end
      end
      out
    end

    def parse_signature_comment(text)
      t = text.to_s.strip
      t = t.sub(/^#\s*/, "")

      if (match = t.match(/^->\s*(.+)$/))
        return { params: [], returns: parse_return_types(match[1]) }
      end

      # match (params) -> returns
      m = t.match(/^\(([^)]*)\)\s*->\s*(.+)$/)
      if m
        params = m[1].strip
        ret = m[2].strip
        param_types = params.empty? ? [] : split_type_list(params)
        return_types = parse_return_types(ret)
        return { params: param_types, returns: return_types }
      end

      if (match = t.match(/^(.+?)\s*->\s*(.+)$/))
        return(
          {
            params: split_type_list(match[1]),
            returns: parse_return_types(match[2])
          }
        )
      end

      # match (params) only
      m = t.match(/^\(([^)]*)\)\s*$/)
      return nil unless m
      params = m[1].strip
      param_types = params.empty? ? [] : split_type_list(params)
      { params: param_types, returns: [] }
    end

    def split_type_list(s)
      # split on commas, but respect nested parens/brackets/braces
      parts = []
      depth = 0
      cur = +""
      s.each_char do |ch|
        case ch
        when "(", "[", "{", "<"
          depth += 1
          cur << ch
        when ")", "]", "}", ">"
          depth -= 1
          cur << ch
        when ","
          if depth == 0
            parts << cur.strip
            cur = +""
          else
            cur << ch
          end
        else
          cur << ch
        end
      end
      parts << cur.strip unless cur.strip.empty?
      parts
    end

    def parse_return_types(s)
      t = s.strip
      if t.start_with?("(") && t.end_with?(")")
        split_type_list(t[1..-2])
      else
        [t]
      end
    end

    def parse_go_type(str)
      s = str.to_s.strip
      return Ident("any") if s.empty? || s == "any"
      if s.start_with?("*")
        return(
          SyntaxTree::Go::StarExpr.new(
            star: nil,
            x: parse_go_type(s[1..].strip)
          )
        )
      end
      if s.start_with?("[]")
        return(
          SyntaxTree::Go::ArrayType.new(
            lbrack: nil,
            len: nil,
            elt: parse_go_type(s[2..].strip)
          )
        )
      end
      if s.start_with?("map[")
        # find matching ]
        depth = 0
        i = 4
        while i < s.length
          ch = s[i]
          depth += 1 if ch == "["
          depth -= 1 if ch == "]"
          break if ch == "]" && depth == 0
          i += 1
        end
        key = s[4...i]
        val = s[(i + 1)..].to_s.strip
        return(
          SyntaxTree::Go::MapType.new(
            map: nil,
            key: parse_go_type(key),
            value: parse_go_type(val)
          )
        )
      end
      if s.start_with?("func(")
        # simple func type: func(...) ...
        return Ident(s) # fallback - rare in our corpus
      end
      # selector type like pkg.Type
      if s.include?(".") && !s.include?(" ")
        parts = s.split(".", 2)
        return SelectorExpr(Ident(parts[0]), parts[1])
      end
      Ident(s)
    end

    def type_from_node(node)
      case node
      when SyntaxTree::ConstRef
        Ident(node.constant.value)
      when SyntaxTree::VarRef
        if node.value.is_a?(SyntaxTree::Ident) ||
             node.value.is_a?(SyntaxTree::Const)
          name = node.value.value
          return build_proc_type([], nil) if name == "Proc"
          Ident(name)
        elsif node.value.is_a?(SyntaxTree::IVar)
          # @User => *User (pointer type in type position)
          name = node.value.value.delete_prefix("@")
          SyntaxTree::Go::StarExpr.new(star: nil, x: Ident(name))
        else
          Ident(node.to_s)
        end
      when SyntaxTree::IVar
        name = node.value.delete_prefix("@")
        SyntaxTree::Go::StarExpr.new(star: nil, x: Ident(name))
      when SyntaxTree::VCall
        name = node.value.value
        return build_proc_type([], nil) if name == "Proc"
        Ident(name)
      when SyntaxTree::Ident
        return build_proc_type([], nil) if node.value == "Proc"
        Ident(node.value)
      when SyntaxTree::CallNode
        recv = node.receiver
        msg = node.message
        msg_name =
          (
            if msg.is_a?(SyntaxTree::Ident) || msg.is_a?(SyntaxTree::Const)
              msg.value
            else
              msg.to_s
            end
          )
        # ptr(Type) / ref(Type) => *Type in type position
        if recv.nil? && %w[ptr ref].include?(msg_name)
          args =
            (
              if node.arguments.is_a?(SyntaxTree::ArgParen)
                node.arguments.arguments.parts
              else
                (
                  if node.arguments.is_a?(SyntaxTree::Args)
                    node.arguments.parts
                  else
                    []
                  end
                )
              end
            )
          if args[0]
            return(
              SyntaxTree::Go::StarExpr.new(
                star: nil,
                x: type_from_node(args[0])
              )
            )
          end
        end
        # Array[T] => []T, Array[T,n] => [n]T, Hash[K,V] => map[K]V
        # handle receiver.ident as pkg.Type
        if recv.nil? && %w[Array Hash].include?(msg_name)
          # not expected, but handle
        end
        if recv.is_a?(SyntaxTree::VarRef) &&
             (
               recv.value.is_a?(SyntaxTree::Ident) ||
                 recv.value.is_a?(SyntaxTree::Const)
             )
          rname = recv.value.value
          if rname == "Array" && msg_name == "[]"
            args =
              (
                if node.arguments.is_a?(SyntaxTree::ArgParen)
                  node.arguments.arguments.parts
                else
                  (
                    if node.arguments.is_a?(SyntaxTree::Args)
                      node.arguments.parts
                    else
                      []
                    end
                  )
                end
              )
            elt = args[0] ? type_from_node(args[0]) : Ident("any")
            len_node = args[1] ? visit(args[1]) : nil
            return(
              SyntaxTree::Go::ArrayType.new(
                lbrack: nil,
                len: len_node,
                elt: elt
              )
            )
          end
          if rname == "Hash" && msg_name == "[]"
            args =
              (
                if node.arguments.is_a?(SyntaxTree::ArgParen)
                  node.arguments.arguments.parts
                else
                  (
                    if node.arguments.is_a?(SyntaxTree::Args)
                      node.arguments.parts
                    else
                      []
                    end
                  )
                end
              )
            k = args[0] ? type_from_node(args[0]) : Ident("any")
            v = args[1] ? type_from_node(args[1]) : Ident("any")
            return SyntaxTree::Go::MapType.new(map: nil, key: k, value: v)
          end
        end
        # pkg.Type (selector-like CallNode) or Type[] style
        if msg_name == "[]" && recv
          r = type_from_node(recv)
          # r might be ident Array/Hash - handle above; otherwise generic index
          args =
            (
              if node.arguments.is_a?(SyntaxTree::ArgParen)
                node.arguments.arguments.parts
              else
                (
                  if node.arguments.is_a?(SyntaxTree::Args)
                    node.arguments.parts
                  else
                    []
                  end
                )
              end
            )
          if r.is_a?(SyntaxTree::Go::Ident) && r.name == "Array"
            elt = args[0] ? type_from_node(args[0]) : Ident("any")
            len_node = args[1] ? visit(args[1]) : nil
            return(
              SyntaxTree::Go::ArrayType.new(
                lbrack: nil,
                len: len_node,
                elt: elt
              )
            )
          end
          if r.is_a?(SyntaxTree::Go::Ident) && r.name == "Hash"
            k = args[0] ? type_from_node(args[0]) : Ident("any")
            v = args[1] ? type_from_node(args[1]) : Ident("any")
            return SyntaxTree::Go::MapType.new(map: nil, key: k, value: v)
          end
        end
        # pkg.Type or Type.Field as selector type (no args)
        if node.arguments.nil?
          recv_ident =
            case recv
            when SyntaxTree::VarRef
              if recv.value.is_a?(SyntaxTree::Ident) ||
                   recv.value.is_a?(SyntaxTree::Const)
                recv.value.value
              end
            when SyntaxTree::VCall
              if recv.value.is_a?(SyntaxTree::Ident) ||
                   recv.value.is_a?(SyntaxTree::Const)
                recv.value.value
              end
            when SyntaxTree::Const
              recv.value
            end
          if recv_ident
            sel =
              (
                if msg.is_a?(SyntaxTree::Ident) || msg.is_a?(SyntaxTree::Const)
                  msg.value
                else
                  msg_name
                end
              )
            return SelectorExpr(Ident(recv_ident), sel)
          end
          # recv might already be a Go type node-ish from recursion? no, recv is Ruby node
          recv_type =
            begin
              type_from_node(recv)
            rescue StandardError
              nil
            end
          if recv_type.is_a?(SyntaxTree::Go::Ident)
            sel =
              (
                if msg.is_a?(SyntaxTree::Ident) || msg.is_a?(SyntaxTree::Const)
                  msg.value
                else
                  msg_name
                end
              )
            return SelectorExpr(recv_type, sel)
          end
        end
        parse_go_type(node.to_s)
      when SyntaxTree::ARef
        # Proc[...] or Proc[...][...] => func type
        proc_info = proc_type_parts(node)
        return build_proc_type(proc_info[0], proc_info[1]) if proc_info

        recv = node.collection
        if recv.is_a?(SyntaxTree::VarRef) &&
             (
               recv.value.is_a?(SyntaxTree::Ident) ||
                 recv.value.is_a?(SyntaxTree::Const)
             )
          rname = recv.value.value
          args =
            (
              if node.index.is_a?(SyntaxTree::Args)
                node.index.parts
              else
                Array(node.index)
              end
            )
          if rname == "Array"
            elt = args[0] ? type_from_node(args[0]) : Ident("any")
            len_node = args[1] ? visit(args[1]) : nil
            return(
              SyntaxTree::Go::ArrayType.new(
                lbrack: nil,
                len: len_node,
                elt: elt
              )
            )
          end
          if rname == "Hash"
            k = args[0] ? type_from_node(args[0]) : Ident("any")
            v = args[1] ? type_from_node(args[1]) : Ident("any")
            return SyntaxTree::Go::MapType.new(map: nil, key: k, value: v)
          end
        end
        parse_go_type(node.to_s)
      when SyntaxTree::ConstPathRef
        left = type_from_node(node.parent)
        right = node.constant.value
        if left.is_a?(SyntaxTree::Go::Ident)
          SelectorExpr(left, right)
        else
          Ident(right)
        end
      when SyntaxTree::SymbolLiteral
        parse_go_type(node.value.value.to_s)
      when SyntaxTree::Const
        return build_proc_type([], nil) if node.value == "Proc"
        Ident(node.value)
      when SyntaxTree::StringLiteral
        parse_go_type(string_value(node).to_s)
      else
        parse_go_type(node.to_s)
      end
    end

    def proc_type_parts(node)
      # Returns [params_parts, returns_parts_or_nil] if node is Proc[...] or Proc[...][...]
      return nil unless node.is_a?(SyntaxTree::ARef)
      inner = node.collection
      args2 =
        (
          if node.index.is_a?(SyntaxTree::Args)
            node.index.parts
          else
            Array(node.index)
          end
        )
      if inner.is_a?(SyntaxTree::ARef)
        base = inner.collection
        base_name = type_ident_name(base)
        return nil unless base_name == "Proc"
        params =
          (
            if inner.index.is_a?(SyntaxTree::Args)
              inner.index.parts
            else
              Array(inner.index)
            end
          )
        return params, args2
      end
      base_name = type_ident_name(inner)
      return nil unless base_name == "Proc"
      [args2, nil]
    end

    def type_ident_name(node)
      case node
      when SyntaxTree::VarRef
        if node.value.is_a?(SyntaxTree::Ident) ||
             node.value.is_a?(SyntaxTree::Const)
          node.value.value
        end
      when SyntaxTree::VCall
        if node.value.is_a?(SyntaxTree::Ident) ||
             node.value.is_a?(SyntaxTree::Const)
          node.value.value
        end
      when SyntaxTree::ConstRef
        node.constant.value
      when SyntaxTree::Ident, SyntaxTree::Const
        node.value
      else
        nil
      end
    end

    def build_proc_type(param_nodes, return_nodes)
      params =
        Array(param_nodes).map do |n|
          SyntaxTree::Go::Field.new(
            doc: nil,
            names: [],
            type: type_from_node(n),
            tag: nil,
            comment: nil
          )
        end
      params_list =
        SyntaxTree::Go::FieldList.new(opening: nil, list: params, closing: nil)
      results_list = nil
      if return_nodes
        rets =
          Array(return_nodes).map do |n|
            SyntaxTree::Go::Field.new(
              doc: nil,
              names: [],
              type: type_from_node(n),
              tag: nil,
              comment: nil
            )
          end
        results_list =
          SyntaxTree::Go::FieldList.new(opening: nil, list: rets, closing: nil)
      end
      SyntaxTree::Go::FuncType.new(
        func: nil,
        type_params: nil,
        params: params_list,
        results: results_list
      )
    end

    def assign_target_name(node, _ctx = self)
      case node
      when SyntaxTree::VarField
        name = node.value
        if name.is_a?(SyntaxTree::IVar)
          n = name.value.delete_prefix("@")
          return(
            SyntaxTree::Go::UnaryExpr.new(
              op_pos: nil,
              op: "&".to_sym,
              x: SyntaxTree::Go::Ident.new(name: n, location: nil, comments: [])
            )
          )
        end
        if name.is_a?(SyntaxTree::CVar)
          n = name.value.delete_prefix("@@")
          return(
            SyntaxTree::Go::StarExpr.new(
              star: nil,
              x: SyntaxTree::Go::Ident.new(name: n, location: nil, comments: [])
            )
          )
        end
        name = name.value if name.is_a?(SyntaxTree::Ident) ||
          name.is_a?(SyntaxTree::Const)
        name.to_s
      when SyntaxTree::Ident
        node.value
      when SyntaxTree::IVar
        n = node.value.delete_prefix("@")
        SyntaxTree::Go::UnaryExpr.new(
          op_pos: nil,
          op: "&".to_sym,
          x: SyntaxTree::Go::Ident.new(name: n, location: nil, comments: [])
        )
      when SyntaxTree::CVar
        n = node.value.delete_prefix("@@")
        SyntaxTree::Go::StarExpr.new(
          star: nil,
          x: SyntaxTree::Go::Ident.new(name: n, location: nil, comments: [])
        )
      when SyntaxTree::ConstRef
        node.constant.value
      when SyntaxTree::VarRef
        if node.value.is_a?(SyntaxTree::IVar)
          n = node.value.value.delete_prefix("@")
          return(
            SyntaxTree::Go::UnaryExpr.new(
              op_pos: nil,
              op: "&".to_sym,
              x: SyntaxTree::Go::Ident.new(name: n, location: nil, comments: [])
            )
          )
        end
        if node.value.is_a?(SyntaxTree::CVar)
          n = node.value.value.delete_prefix("@@")
          return(
            SyntaxTree::Go::StarExpr.new(
              star: nil,
              x: SyntaxTree::Go::Ident.new(name: n, location: nil, comments: [])
            )
          )
        end
        node.value.is_a?(SyntaxTree::Ident) ? node.value.value : node.value.to_s
      when SyntaxTree::ARefField, SyntaxTree::Field, SyntaxTree::ConstPathField
        node
      else
        node.to_s
      end
    end

    def assign_targets(node, _ctx = self)
      case node
      when SyntaxTree::VarField, SyntaxTree::Ident, SyntaxTree::ConstRef,
           SyntaxTree::ARefField, SyntaxTree::Field, SyntaxTree::ConstPathField
        [assign_target_name(node)]
      when SyntaxTree::MLHS
        node.parts.map { |p| assign_target_name(p) }
      else
        [assign_target_name(node)]
      end
    end

    def build_assign(targets, values, ctx = self)
      simple = targets.all? { |t| t.is_a?(String) || t.is_a?(Symbol) }
      names =
        targets.map { |t| t.is_a?(String) || t.is_a?(Symbol) ? t.to_s : nil }

      # Package scope: var decl
      if package_scope?
        value = values.length == 1 ? values.first : array_composite(values)
        if simple
          if names.length > 1 && values.length != names.length
            spec =
              SyntaxTree::Go::ValueSpec.new(
                doc: nil,
                names: names.map { |n| Ident(n) },
                type: nil,
                values: [value],
                comment: nil
              )
            return(
              SyntaxTree::Go::GenDecl.new(
                doc: nil,
                tok_pos: nil,
                tok: "var",
                lparen: nil,
                specs: [spec],
                rparen: nil
              )
            )
          end
          specs =
            names.map.with_index do |name, i|
              v =
                (
                  if values.length == names.length
                    values[i]
                  else
                    (i == 0 ? value : nil)
                  end
                )
              SyntaxTree::Go::ValueSpec.new(
                doc: nil,
                names: [Ident(name)],
                type: nil,
                values: v ? [v] : [],
                comment: nil
              )
            end
          return(
            SyntaxTree::Go::GenDecl.new(
              doc: nil,
              tok_pos: nil,
              tok: "var",
              lparen: nil,
              specs: specs,
              rparen: nil
            )
          )
        end
        # fallback
        lhs =
          targets.map do |t|
            if t.is_a?(String)
              Ident(t)
            else
              (t.is_a?(SyntaxTree::Go::Node) ? t : visit(t))
            end
          end
        return(
          SyntaxTree::Go::AssignStmt.new(
            lhs: lhs,
            tok_pos: nil,
            tok: "=",
            rhs: values.length == 1 ? values : [array_composite(values)]
          )
        )
      end

      # Function scope
      if simple
        fresh =
          names.any? do |n|
            n.match?(/\A[\w]+\z/) && !declared_in_current_scope?(n)
          end
        names.each { |n| declare(n) }
        tok = fresh ? ":=" : "="
        lhs = names.map { |n| Ident(n) }
      else
        lhs =
          targets.map do |t|
            if t.is_a?(String)
              Ident(t)
            else
              (t.is_a?(SyntaxTree::Go::Node) ? t : visit(t))
            end
          end
        lhs.each { |n| declare(n.name) if n.is_a?(SyntaxTree::Go::Ident) }
        tok = "="
      end

      rhs =
        if values.length == 1
          v = values.first
          if lhs.length == 1 && lhs.first.is_a?(SyntaxTree::Go::SelectorExpr)
            if v.is_a?(SyntaxTree::Go::CallExpr) &&
                 v.fun.is_a?(SyntaxTree::Go::SelectorExpr) &&
                 v.fun.x.is_a?(SyntaxTree::Go::CallExpr)
              v = SyntaxTree::Go::ParenExpr.new(lparen: nil, x: v, rparen: nil)
            elsif v.is_a?(SyntaxTree::Go::Ident)
              v = SyntaxTree::Go::ParenExpr.new(lparen: nil, x: v, rparen: nil)
            end
          end
          [v]
        elsif values.length == lhs.length
          values
        else
          [array_composite(values)]
        end

      SyntaxTree::Go::AssignStmt.new(lhs: lhs, tok_pos: nil, tok: tok, rhs: rhs)
    end

    def array_composite(values)
      SyntaxTree::Go::CompositeLit.new(
        type:
          SyntaxTree::Go::ArrayType.new(
            lbrack: nil,
            len: nil,
            elt: Ident("any")
          ),
        lbrace: nil,
        elts: values,
        rbrace: nil,
        incomplete: false
      )
    end

    def array_elements(contents)
      case contents
      when SyntaxTree::Args
        contents.parts
      when Array
        contents
      else
        [contents]
      end
    end

    def is_range_node?(node)
      if defined?(SyntaxTree::RangeNode) && node.is_a?(SyntaxTree::RangeNode)
        return true
      end
      return true if defined?(SyntaxTree::Dot2) && node.is_a?(SyntaxTree::Dot2)
      return true if defined?(SyntaxTree::Dot3) && node.is_a?(SyntaxTree::Dot3)
      false
    end

    def unwrap(node)
      node = node.contents if node.is_a?(SyntaxTree::Paren)
      if node.is_a?(SyntaxTree::Statements) && node.body.length == 1
        node = node.body.first
      end
      node
    end

    def zero_node?(node)
      node.is_a?(SyntaxTree::Int) && node.value.to_s == "0"
    end

    def wrap_chain_call(node)
      return node if node.is_a?(SyntaxTree::Go::ParenExpr)
      if node.is_a?(SyntaxTree::Go::CallExpr) &&
           node.fun.is_a?(SyntaxTree::Go::SelectorExpr) &&
           node.fun.x.is_a?(SyntaxTree::Go::CallExpr)
        return SyntaxTree::Go::ParenExpr.new(lparen: nil, x: node, rparen: nil)
      end
      node
    end

    def fix_receiver_assigns(node, names = %w[this self])
      case node
      when SyntaxTree::Go::AssignStmt
        if node.tok == ":=" &&
             node.lhs.any? { |l|
               l.is_a?(SyntaxTree::Go::Ident) && names.include?(l.name)
             }
          return(
            SyntaxTree::Go::AssignStmt.new(
              lhs: node.lhs,
              tok_pos: node.tok_pos,
              tok: "=",
              rhs: node.rhs
            )
          )
        end
        node
      when SyntaxTree::Go::BlockStmt
        SyntaxTree::Go::BlockStmt.new(
          lbrace: node.lbrace,
          list: node.list.map { |s| fix_receiver_assigns(s, names) },
          rbrace: node.rbrace
        )
      when SyntaxTree::Go::IfStmt
        SyntaxTree::Go::IfStmt.new(
          if_: node.if_,
          init: node.init,
          cond: node.cond,
          body: fix_receiver_assigns(node.body, names),
          else_: node.else_ ? fix_receiver_assigns(node.else_, names) : nil
        )
      when SyntaxTree::Go::ForStmt
        SyntaxTree::Go::ForStmt.new(
          for_: node.for_,
          init: node.init,
          cond: node.cond,
          post: node.post,
          body: fix_receiver_assigns(node.body, names)
        )
      when SyntaxTree::Go::RangeStmt
        SyntaxTree::Go::RangeStmt.new(
          for_: node.for_,
          key: node.key,
          value: node.value,
          tok_pos: node.tok_pos,
          tok: node.tok,
          range: node.range,
          x: node.x,
          body: fix_receiver_assigns(node.body, names)
        )
      when SyntaxTree::Go::SwitchStmt
        SyntaxTree::Go::SwitchStmt.new(
          switch: node.switch,
          init: node.init,
          tag: node.tag,
          body: fix_receiver_assigns(node.body, names)
        )
      when SyntaxTree::Go::TypeSwitchStmt
        SyntaxTree::Go::TypeSwitchStmt.new(
          switch: node.switch,
          init: node.init,
          assign: node.assign,
          body: fix_receiver_assigns(node.body, names)
        )
      when SyntaxTree::Go::SelectStmt
        SyntaxTree::Go::SelectStmt.new(
          select: node.select,
          body: fix_receiver_assigns(node.body, names)
        )
      when SyntaxTree::Go::CaseClause
        SyntaxTree::Go::CaseClause.new(
          case_: node.case_,
          list: node.list,
          colon: node.colon,
          body: node.body.map { |s| fix_receiver_assigns(s, names) }
        )
      when SyntaxTree::Go::CommClause
        SyntaxTree::Go::CommClause.new(
          case_: node.case_,
          comm: node.comm,
          colon: node.colon,
          body: node.body.map { |s| fix_receiver_assigns(s, names) }
        )
      else
        node
      end
    end

    def block_params(block)
      bv = block.block_var
      return [] unless bv

      params = bv.params
      params = params.contents if params.is_a?(SyntaxTree::Paren)
      return [] unless params.is_a?(SyntaxTree::Params)

      (params.requireds || []).map do |p|
        p.is_a?(SyntaxTree::Ident) ? p.value : p.to_s
      end
    end

    def build_each(node, ctx)
      call = node.call
      block = node.block
      params = block_params(block)
      raw_recv = unwrap(call.receiver)
      body =
        BlockStmt(
          scoped(params) do
            visit_all(stmt_body(block.bodystmt)).map { |s| stmtify(s) }
          end
        )

      # (0...n).each or (0..n).each
      if is_range_node?(raw_recv)
        key = params[0] || "_"
        declare(key) unless key == "_"
        left = raw_recv.left ? visit(raw_recv.left) : Ident("0")
        right = raw_recv.right ? visit(raw_recv.right) : nil
        if zero_node?(raw_recv.left) && right
          return(
            SyntaxTree::Go::RangeStmt.new(
              key: Ident(key),
              value: nil,
              tok_pos: nil,
              tok: ":=",
              range: nil,
              x: right,
              body: body,
              for_: nil
            )
          )
        end
        return(
          SyntaxTree::Go::RangeStmt.new(
            key: Ident(key),
            value: nil,
            tok_pos: nil,
            tok: ":=",
            range: nil,
            x: right || left,
            body: body,
            for_: nil
          )
        )
      end

      receiver = visit(call.receiver)

      if call.message.value == "times"
        key = params.first || "_"
        declare(key) unless key == "_"
        return(
          SyntaxTree::Go::RangeStmt.new(
            key: Ident(key),
            value: nil,
            tok_pos: nil,
            tok: ":=",
            range: nil,
            x: receiver,
            body: body,
            for_: nil
          )
        )
      end

      key = params[0] || "_"
      val = params[1]
      if val
        declare(key) unless key == "_"
        declare(val) unless val == "_"
        return(
          SyntaxTree::Go::RangeStmt.new(
            key: Ident(key),
            value: Ident(val),
            tok_pos: nil,
            tok: ":=",
            range: nil,
            x: receiver,
            body: body,
            for_: nil
          )
        )
      end

      declare(key) unless key == "_"
      SyntaxTree::Go::RangeStmt.new(
        key: Ident(key),
        value: nil,
        tok_pos: nil,
        tok: ":=",
        range: nil,
        x: receiver,
        body: body,
        for_: nil
      )
    end

    def build_select(node, ctx)
      # Simple: build select stmt with comm clauses
      block = node.block
      clauses = []
      stmts = stmt_body(block.bodystmt)
      stmts.each do |stmt|
        clause = build_comm_clause(stmt, ctx)
        clauses << clause if clause
      end
      SyntaxTree::Go::SelectStmt.new(
        select: nil,
        body:
          SyntaxTree::Go::BlockStmt.new(lbrace: nil, list: clauses, rbrace: nil)
      )
    end

    def build_comm_clause(stmt, ctx)
      # pattern: c << <channel-expr> { body }  as Binary :<< with MethodAddBlock rhs
      if stmt.is_a?(SyntaxTree::Binary) && stmt.operator == :<<
        rhs = stmt.right
        if rhs.is_a?(SyntaxTree::MethodAddBlock)
          chan_expr = visit(rhs.call)
          # Unwrap: if it's a call expr wrapping, but for select guard we want the recv expr
          # In select, `c << ch { ... }` means case <-ch: or case ch <- ...
          # We need to look at ruby source semantics. Check golden.
          comm =
            SyntaxTree::Go::ExprStmt.new(
              x:
                SyntaxTree::Go::UnaryExpr.new(
                  op_pos: nil,
                  op: "<-".to_sym,
                  x: chan_expr
                )
            )
          body = visit_all(stmt_body(rhs.block.bodystmt)).map { |s| stmtify(s) }
          return(
            SyntaxTree::Go::CommClause.new(
              case_: nil,
              comm: comm,
              colon: nil,
              body: body
            )
          )
        end
      end
      # default: case with no comm
      body = visit_all(Array(stmt)).map { |s| stmtify(s) }
      SyntaxTree::Go::CommClause.new(
        case_: nil,
        comm: nil,
        colon: nil,
        body: body
      )
    end

    class UnsupportedNode < StandardError
    end
  end
end
