# frozen_string_literal: true

require "syntax_tree"
require_relative "matcher"
require_relative "go/dsl"

module Gob
  class Transpiler
    include Go::DSL

    attr_reader :matcher, :source

    def initialize(matcher: nil)
      @matcher = matcher || Gob.default_matcher
      @scopes = [Set.new]
      @package_depth = 0
    end

    def transpile(source)
      @source = source
      program = SyntaxTree.parse(source)
      visit(program)
    end

    def visit(node)
      return nil if node.nil?
      return node.map { |n| visit(n) }.compact.flatten if node.is_a?(Array)

      result = matcher.match(node, self)
      return nil if result == Matcher::DROP
      return result unless result == Matcher::MISS

      raise UnsupportedNode, "No rule matched #{node.class}: #{node.inspect[0, 200]}"
    end

    def visit_all(nodes)
      Array(nodes).flat_map do |n|
        result = visit(n)
        case result
        when nil then []
        when Array then result
        else [result]
        end
      end
    end

    def param_name_list(node)
      params = node
      params = params.contents if params.is_a?(SyntaxTree::Paren)
      return [] unless params.is_a?(SyntaxTree::Params)

      (params.requireds || []).map { |p| p.is_a?(SyntaxTree::Ident) ? p.value : p.to_s }
    end

    def visit_params(node)
      param_name_list(node).map { |name| SyntaxTree::Go::Field.new(names: [ident(name)], type: nil) }
    end

    def visit_args(node)
      return [] if node.nil?

      args_node = node
      args_node = args_node.arguments if args_node.is_a?(SyntaxTree::ArgParen)
      parts = args_node.is_a?(SyntaxTree::Args) ? args_node.parts : Array(args_node)
      visit_all(parts)
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
      when SyntaxTree::Go::ExprStmt, SyntaxTree::Go::AssignStmt, SyntaxTree::Go::DeclStmt,
           SyntaxTree::Go::ReturnStmt, SyntaxTree::Go::IfStmt, SyntaxTree::Go::ForStmt,
           SyntaxTree::Go::RangeStmt, SyntaxTree::Go::SwitchStmt, SyntaxTree::Go::SelectStmt,
           SyntaxTree::Go::BlockStmt, SyntaxTree::Go::BranchStmt, SyntaxTree::Go::DeferStmt,
           SyntaxTree::Go::GoStmt, SyntaxTree::Go::SendStmt, SyntaxTree::Go::IncDecStmt,
           SyntaxTree::Go::LabeledStmt, SyntaxTree::Go::EmptyStmt, SyntaxTree::Go::TypeSwitchStmt,
           SyntaxTree::Go::CaseClause, SyntaxTree::Go::CommClause, SyntaxTree::Go::BadStmt,
           SyntaxTree::Go::GenDecl
        node
      else
        if node.class.name.include?("Expr") || node.is_a?(SyntaxTree::Go::Ident) || node.is_a?(SyntaxTree::Go::BasicLit)
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

    def declared?(name)
      @scopes.any? { |s| s.include?(name) }
    end

    def package_scope?
      @scopes.length <= 1
    end

    def string_value(node)
      case node
      when SyntaxTree::StringLiteral
        node.parts.map { |p| p.is_a?(SyntaxTree::TStringContent) ? p.value : "" }.join
      else
        nil
      end
    end

    def const_name(node)
      case node
      when SyntaxTree::ConstRef then node.constant.value
      when SyntaxTree::ConstPathRef
        left = const_name(node.parent)
        right = node.constant.value
        left ? "#{left}::#{right}" : right
      when SyntaxTree::Const then node.value
      when SyntaxTree::VarRef then node.value.value
      else
        nil
      end
    end

    def assign_target_name(node, _ctx = self)
      case node
      when SyntaxTree::VarField
        name = node.value
        name = name.value if name.is_a?(SyntaxTree::Ident)
        name.to_s
      when SyntaxTree::Ident
        node.value
      when SyntaxTree::ConstRef
        node.constant.value
      when SyntaxTree::VarRef
        node.value.is_a?(SyntaxTree::Ident) ? node.value.value : node.value.to_s
      else
        node.to_s
      end
    end

    def assign_targets(node, _ctx = self)
      case node
      when SyntaxTree::VarField, SyntaxTree::Ident, SyntaxTree::ConstRef
        [assign_target_name(node)]
      when SyntaxTree::MLHS
        node.parts.map { |p| assign_target_name(p) }
      else
        [assign_target_name(node)]
      end
    end

    def build_assign(targets, values, ctx = self)
      names = targets.map { |t| t.to_s }
      # Package scope: var decl
      if package_scope?
        value = values.length == 1 ? values.first : array_composite(values)
        specs = names.map.with_index do |name, i|
          v = values.length == names.length ? values[i] : (i == 0 ? value : nil)
          SyntaxTree::Go::ValueSpec.new(
            doc: nil, names: [ident(name)], type: nil,
            values: v ? [v] : [], comment: nil
          )
        end
        # If single multi-value RHS assigned to multiple names, use one spec
        if names.length > 1 && values.length != names.length
          spec = SyntaxTree::Go::ValueSpec.new(
            doc: nil, names: names.map { |n| ident(n) }, type: nil,
            values: [value], comment: nil
          )
          return SyntaxTree::Go::GenDecl.new(doc: nil, tok_pos: nil, tok: "var", lparen: nil, specs: [spec], rparen: nil)
        end
        return SyntaxTree::Go::GenDecl.new(doc: nil, tok_pos: nil, tok: "var", lparen: nil, specs: specs, rparen: nil)
      end

      # Function scope
      fresh = names.any? { |n| n.match?(/\A[\w]+\z/) && !declared?(n) }
      names.each { |n| declare(n) }
      tok = fresh ? ":=" : "="

      rhs = if values.length == 1
              values
            else
              [array_composite(values)]
            end

      SyntaxTree::Go::AssignStmt.new(
        lhs: names.map { |n| ident(n) },
        tok_pos: nil,
        tok: tok,
        rhs: rhs
      )
    end

    def array_composite(values)
      SyntaxTree::Go::CompositeLit.new(
        type: SyntaxTree::Go::ArrayType.new(lbrack: nil, len: nil, elt: ident("any")),
        lbrace: nil, elts: values, rbrace: nil, incomplete: false
      )
    end

    def array_elements(contents)
      case contents
      when SyntaxTree::Args then contents.parts
      when Array then contents
      else [contents]
      end
    end

    def block_params(block)
      bv = block.block_var
      return [] unless bv

      params = bv.params
      params = params.contents if params.is_a?(SyntaxTree::Paren)
      return [] unless params.is_a?(SyntaxTree::Params)

      (params.requireds || []).map { |p| p.is_a?(SyntaxTree::Ident) ? p.value : p.to_s }
    end

    def build_each(node, ctx)
      call = node.call
      block = node.block
      params = block_params(block)
      receiver = visit(call.receiver)

      body_stmts = scoped(params) { visit_all(stmt_body(block.bodystmt)).map { |s| stmtify(s) } }
      body = block_stmt(list: body_stmts)

      if call.message.value == "times"
        key = params.first || "_"
        declare(key) unless key == "_"
        return SyntaxTree::Go::RangeStmt.new(
          key: ident(key), value: nil, tok_pos: nil, tok: ":=", range: nil, x: receiver, body: body, for_: nil
        )
      end

      # .each
      if receiver.is_a?(SyntaxTree::Go::CompositeLit) && receiver.type.is_a?(SyntaxTree::Go::MapType)
        # map each? uncommon
      end

      # range over receiver
      key = params[0] || "_"
      val = params[1]
      if val
        declare(key) unless key == "_"
        declare(val) unless val == "_"
        return SyntaxTree::Go::RangeStmt.new(
          key: ident(key), value: ident(val), tok_pos: nil, tok: ":=", range: nil, x: receiver, body: body, for_: nil
        )
      end

      declare(key) unless key == "_"
      SyntaxTree::Go::RangeStmt.new(
        key: ident(key), value: nil, tok_pos: nil, tok: ":=", range: nil, x: receiver, body: body, for_: nil
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
      SyntaxTree::Go::SelectStmt.new(select: nil, body: SyntaxTree::Go::BlockStmt.new(lbrace: nil, list: clauses, rbrace: nil))
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
          comm = SyntaxTree::Go::ExprStmt.new(x: SyntaxTree::Go::UnaryExpr.new(op_pos: nil, op: "<-".to_sym, x: chan_expr))
          body = visit_all(stmt_body(rhs.block.bodystmt)).map { |s| stmtify(s) }
          return SyntaxTree::Go::CommClause.new(case_: nil, comm: comm, colon: nil, body: body)
        end
      end
      # default: case with no comm
      body = visit_all(Array(stmt)).map { |s| stmtify(s) }
      SyntaxTree::Go::CommClause.new(case_: nil, comm: nil, colon: nil, body: body)
    end

    class UnsupportedNode < StandardError; end
  end
end
