# frozen_string_literal: true

module Gob
  module Rules
    module_function

    def register(matcher)
      matcher.rule(:program) do |node|
        next unless node.is_a?(SyntaxTree::Program)

        body = visit_all(node.statements.body)
        # Flatten: imports collected, funcs/decls collected
        decls = []
        imports = []
        package = "main"

        body.each do |item|
          case item
          when SyntaxTree::Go::GenDecl
            if item.tok.to_s == "import"
              decls << item
              imports.concat(item.specs)
            else
              decls << item
            end
          when SyntaxTree::Go::FuncDecl, SyntaxTree::Go::DeclStmt
            decls << item
          when Hash
            # metadata from module/import handling
            package = item[:package] if item[:package]
            decls.concat(Array(item[:decls]))
            imports.concat(Array(item[:imports]))
          when SyntaxTree::Go::Node
            decls << item
          when nil
            # skip
          end
        end

        SyntaxTree::Go::File.new(
          doc: nil,
          package: nil,
          name: ident(package),
          decls: decls,
          file_start: nil,
          file_end: nil,
          scope: nil,
          imports: imports,
          unresolved: [],
          comments: [],
          go_version: nil
        )
      end

      matcher.rule(:comment) do |node|
        next unless node.is_a?(SyntaxTree::Comment)

        nil # drop comments for now in Go output
      end

      matcher.rule(:void_stmt) do |node|
        next unless node.is_a?(SyntaxTree::VoidStmt)

        nil
      end

      matcher.rule(:require) do |node|
        next unless node.is_a?(SyntaxTree::Command)
        next unless node.message.is_a?(SyntaxTree::Ident) && node.message.value == "require"

        arg = node.arguments.parts.first
        path = string_value(arg)
        next unless path

        gen_decl(tok: "import", specs: [import_spec(path: path)])
      end

      matcher.rule(:module_main) do |node|
        next unless node.is_a?(SyntaxTree::ModuleDeclaration)

        name = const_name(node.constant)
        body_nodes = visit_all(node.bodystmt.statements.body)

        decls = []
        imports = []
        body_nodes.each do |item|
          case item
          when SyntaxTree::Go::GenDecl
            if item.tok.to_s == "import"
              decls << item
              imports.concat(item.specs)
            else
              decls << item
            end
          when SyntaxTree::Go::Node
            decls << item
          when Hash
            decls.concat(Array(item[:decls]))
            imports.concat(Array(item[:imports]))
          end
        end

        { package: name.downcase, decls: decls, imports: imports }
      end

      matcher.rule(:def_node) do |node|
        next unless node.is_a?(SyntaxTree::DefNode)

        name = node.name.value
        params = visit_params(node.params)
        body_stmts = visit_all(node.bodystmt.statements.body)

        func_decl(name: name, params: params, body: body_stmts)
      end

      matcher.rule(:call_node) do |node|
        next unless node.is_a?(SyntaxTree::CallNode)

        receiver = visit(node.receiver)
        msg = node.message
        msg_name = msg.is_a?(SyntaxTree::Const) ? msg.value : msg.value
        args = visit_args(node.arguments)

        fun = if receiver
                selector_expr(x: receiver, sel: msg_name)
              else
                ident(msg_name)
              end

        call_expr(fun: fun, args: args)
      end

      matcher.rule(:vcall) do |node|
        next unless node.is_a?(SyntaxTree::VCall)

        ident(node.value.value)
      end

      matcher.rule(:var_ref_ident) do |node|
        next unless node.is_a?(SyntaxTree::VarRef)
        next unless node.value.is_a?(SyntaxTree::Ident)

        ident(node.value.value)
      end

      matcher.rule(:string_literal) do |node|
        next unless node.is_a?(SyntaxTree::StringLiteral)

        value = node.parts.map { |p| p.is_a?(SyntaxTree::TStringContent) ? p.value : "" }.join
        str_lit(value)
      end

      matcher.rule(:int) do |node|
        next unless node.is_a?(SyntaxTree::Int)

        int_lit(node.value)
      end

      matcher.rule(:float) do |node|
        next unless node.is_a?(SyntaxTree::FloatLiteral)

        float_lit(node.value)
      end
    end

    # Helpers available in rule context via transpiler instance_exec
  end
end
