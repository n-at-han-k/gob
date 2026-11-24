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

    def current_scope
      @scopes.last
    end

    def package_scope?
      @scopes.length <= 1
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
  end
end
