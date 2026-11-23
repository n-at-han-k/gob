# frozen_string_literal: true

module Gob
  module Rules
    module_function

    def register(matcher)
      matcher.rule(:program) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Program)

        body = visit_all(node.statements.body)
        # Flatten: imports collected, funcs/decls collected
        decls = []
        imports = []
        package = "main"

        body.flatten.each do |item|
          case item
          when SyntaxTree::Go::GenDecl
            if item.tok.to_s == "import"
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

        merged_decls = []
        unless imports.empty?
          merged_decls << SyntaxTree::Go::GenDecl.new(
            doc: nil, tok_pos: nil, tok: "import", lparen: nil,
            specs: imports, rparen: nil
          )
        end
        merged_decls.concat(decls)

        SyntaxTree::Go::File.new(
          doc: nil,
          package: nil,
          name: ident(package),
          decls: merged_decls,
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
        next Matcher::MISS unless node.is_a?(SyntaxTree::Comment)

        Matcher::DROP
      end

      matcher.rule(:void_stmt) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::VoidStmt)

        Matcher::DROP
      end

      matcher.rule(:require) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Command)
        next Matcher::MISS unless node.message.is_a?(SyntaxTree::Ident) && node.message.value == "require"

        arg = node.arguments.parts.first
        path = string_value(arg)
        next Matcher::MISS unless path

        gen_decl(tok: "import", specs: [import_spec(path: path)])
      end

      matcher.rule(:command) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

        name = node.message.is_a?(SyntaxTree::Ident) ? node.message.value : node.message.to_s
        next Matcher::DROP if %w[private public protected module_function].include?(name)

        args = visit_args(node.arguments)
        call_expr(fun: ident(name), args: args)
      end

      matcher.rule(:command_call) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::CommandCall)

        receiver = visit(node.receiver)
        msg = node.message
        msg_name = msg.is_a?(SyntaxTree::Const) || msg.is_a?(SyntaxTree::Ident) ? msg.value : msg.to_s
        args = visit_args(node.arguments)
        fun = receiver ? selector_expr(x: receiver, sel: msg_name) : ident(msg_name)
        call_expr(fun: fun, args: args)
      end

      matcher.rule(:module_main) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ModuleDeclaration)

        name = const_name(node.constant)
        body_nodes = visit_all(stmt_body(node.bodystmt))

        decls = []
        imports = []
        body_nodes.flatten.each do |item|
          case item
          when SyntaxTree::Go::GenDecl
            if item.tok.to_s == "import"
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
        next Matcher::MISS unless node.is_a?(SyntaxTree::DefNode)

        name = node.name.value
        param_names = param_name_list(node.params)
        body_stmts = scoped(param_names) do
          visit_all(stmt_body(node.bodystmt)).map { |s| stmtify(s) }
        end
        params = param_names.map { |n| SyntaxTree::Go::Field.new(names: [ident(n)], type: ident("any")) }

        func_decl(name: name, params: params, body: body_stmts)
      end

      matcher.rule(:call_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

        receiver = visit(node.receiver)
        msg = node.message
        msg_name = case msg
                   when SyntaxTree::Const, SyntaxTree::Ident then msg.value
                   when Symbol then msg.to_s
                   else msg.respond_to?(:value) ? msg.value : msg.to_s
                   end

        # defer { ... }.() / go { ... }.() - already a stmt
        if receiver.is_a?(SyntaxTree::Go::DeferStmt) || receiver.is_a?(SyntaxTree::Go::GoStmt)
          inner_call = receiver.is_a?(SyntaxTree::Go::DeferStmt) ? receiver.call : receiver.call
          wrapped = SyntaxTree::Go::CallExpr.new(
            fun: SyntaxTree::Go::SelectorExpr.new(x: inner_call, sel: ident(msg_name)),
            lparen: nil, args: visit_args(node.arguments), ellipsis: nil, rparen: nil
          )
          if receiver.is_a?(SyntaxTree::Go::DeferStmt)
            next SyntaxTree::Go::DeferStmt.new(defer: nil, call: wrapped)
          else
            next SyntaxTree::Go::GoStmt.new(go: nil, call: wrapped)
          end
        end

        # No-arg, no-parens call is a selector/property access in Go golden
        if node.arguments.nil?
          if receiver
            next selector_expr(x: receiver, sel: msg_name)
          else
            next ident(msg_name)
          end
        end

        args = visit_args(node.arguments)
        fun = if receiver
                selector_expr(x: receiver, sel: msg_name)
              else
                ident(msg_name)
              end

        call_expr(fun: fun, args: args)
      end

      matcher.rule(:vcall) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::VCall)

        name = node.value.value
        next Matcher::DROP if %w[private public protected module_function].include?(name)

        ident(name)
      end

      matcher.rule(:var_ref_ident) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)
        next Matcher::MISS unless node.value.is_a?(SyntaxTree::Ident)

        ident(node.value.value)
      end

      matcher.rule(:string_literal) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::StringLiteral)

        value = node.parts.map { |p| p.is_a?(SyntaxTree::TStringContent) ? p.value : "" }.join
        str_lit(value)
      end

      matcher.rule(:int) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Int)

        int_lit(node.value)
      end

      matcher.rule(:float) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::FloatLiteral)

        float_lit(node.value)
      end

      matcher.rule(:bool_nil) do |node|
        case node
        when SyntaxTree::VarRef
          case node.value
          when SyntaxTree::Kw
            case node.value.value
            when "true", "false" then ident(node.value.value)
            when "nil" then ident("nil")
            else next Matcher::MISS
            end
          else
            next Matcher::MISS
          end
        else
          next Matcher::MISS
        end
      end

      matcher.rule(:assign) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Assign)

        targets = assign_targets(node.target, self)
        value = visit(node.value)
        build_assign(targets, [value], self)
      end

      matcher.rule(:massign) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::MAssign)

        targets = node.target.parts.map { |p| assign_target_name(p, self) }
        values = if node.value.is_a?(SyntaxTree::MRHS)
                   node.value.parts.map { |p| visit(p) }
                 else
                   [visit(node.value)]
                 end
        build_assign(targets, values, self)
      end

      matcher.rule(:return) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ReturnNode)

        args = node.arguments
        parts = case args
                when SyntaxTree::Args then args.parts
                when SyntaxTree::ArgParen then args.arguments.parts
                else Array(args)
                end
        results = visit_all(parts)
        SyntaxTree::Go::ReturnStmt.new(return_: nil, results: results)
      end

      matcher.rule(:binary) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Binary)

        left = visit(node.left)
        right = visit(node.right)
        op = node.operator.is_a?(Symbol) ? node.operator.to_s : node.operator.to_s
        SyntaxTree::Go::BinaryExpr.new(x: left, op_pos: nil, op: op.to_sym, y: right)
      end

      matcher.rule(:paren) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Paren)

        inner = node.contents
        next Matcher::MISS if inner.is_a?(SyntaxTree::Params)

        visited = visit(inner)
        visited = visited.first if visited.is_a?(Array) && visited.length == 1
        # Don't wrap FuncLit in extra ParenExpr - Go AST represents (func(){})() as CallExpr with FuncLit fun
        next visited if visited.is_a?(SyntaxTree::Go::FuncLit)
        SyntaxTree::Go::ParenExpr.new(lparen: nil, x: visited, rparen: nil)
      end

      matcher.rule(:array_literal) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ArrayLiteral)

        elts = node.contents ? visit_all(array_elements(node.contents)) : []
        SyntaxTree::Go::CompositeLit.new(
          type: SyntaxTree::Go::ArrayType.new(lbrack: nil, len: nil, elt: ident("any")),
          lbrace: nil,
          elts: elts,
          rbrace: nil,
          incomplete: false
        )
      end

      matcher.rule(:const_ref) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ConstRef)

        ident(node.constant.value)
      end

      matcher.rule(:class_declaration) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ClassDeclaration)

        name = node.constant.constant.value
        body_nodes = stmt_body(node.bodystmt)
        fields = []
        methods = []

        body_nodes.each do |child|
          case child
          when SyntaxTree::Command
            if child.message.is_a?(SyntaxTree::Ident) && child.message.value == "attr_accessor"
              child.arguments.parts.each do |arg|
                fname = case arg
                        when SyntaxTree::SymbolLiteral then arg.value.value
                        else arg.to_s
                        end
                fields << SyntaxTree::Go::Field.new(names: [ident(fname)], type: ident("any"))
              end
            else
              visited = visit(child)
              methods.concat(Array(visited)) if visited
            end
          when SyntaxTree::DefNode
            visited = visit(child)
            # method inside class -> method with receiver? check golden
            if visited.is_a?(SyntaxTree::Go::FuncDecl)
              # convert to method: add receiver
              recv = SyntaxTree::Go::FieldList.new(
                opening: nil,
                list: [SyntaxTree::Go::Field.new(names: [ident("this")], type: ident(name))],
                closing: nil
              )
              body = visited.body ? fix_receiver_assigns(visited.body) : visited.body
              visited = SyntaxTree::Go::FuncDecl.new(
                doc: visited.doc, recv: recv, name: visited.name, type: visited.type, body: body
              )
            end
            methods << visited if visited
          when SyntaxTree::VoidStmt, SyntaxTree::Comment
            next
          else
            visited = visit(child)
            methods.concat(Array(visited)) if visited
          end
        end

        struct_type = SyntaxTree::Go::StructType.new(
          struct: nil,
          fields: SyntaxTree::Go::FieldList.new(opening: nil, list: fields, closing: nil),
          incomplete: false
        )
        type_spec = SyntaxTree::Go::TypeSpec.new(doc: nil, name: ident(name), type_params: nil, assign: nil, type: struct_type, comment: nil)
        type_decl = SyntaxTree::Go::GenDecl.new(doc: nil, tok_pos: nil, tok: "type", lparen: nil, specs: [type_spec], rparen: nil)

        result = [type_decl]
        result.concat(methods)
        result
      end

      matcher.rule(:symbol_literal) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::SymbolLiteral)

        val = node.value
        name = val.is_a?(SyntaxTree::Ident) ? val.value : val.to_s
        ident(name)
      end

      matcher.rule(:dyna_symbol) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::DynaSymbol)

        value = node.parts.map { |p| p.is_a?(SyntaxTree::TStringContent) ? p.value : "" }.join
        ident(value)
      end

      matcher.rule(:label) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Label)

        ident(node.value.chomp(":"))
      end

      matcher.rule(:break_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Break)

        SyntaxTree::Go::BranchStmt.new(tok_pos: nil, tok: "break", label: nil)
      end

      matcher.rule(:next_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Next)

        SyntaxTree::Go::BranchStmt.new(tok_pos: nil, tok: "continue", label: nil)
      end

      matcher.rule(:yield_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::YieldNode)

        args = if node.arguments
                 case node.arguments
                 when SyntaxTree::Paren then visit_args(node.arguments.contents)
                 when SyntaxTree::Args then visit_args(node.arguments)
                 else visit_args(node.arguments)
                 end
               else
                 []
               end
        call_expr(fun: ident("yield"), args: args)
      end



      matcher.rule(:case_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Case)

        tag = node.value ? visit(node.value) : nil
        clauses = []
        cons = node.consequent
        while cons
          case cons
          when SyntaxTree::When
            vals = cons.arguments.parts.flat_map { |p| visit(p).is_a?(Array) ? visit(p) : [visit(p)] }
            body = visit_all(cons.statements.body).map { |s| stmtify(s) }
            clauses << SyntaxTree::Go::CaseClause.new(case_: nil, list: vals, colon: nil, body: body)
            cons = cons.consequent
          when SyntaxTree::Else
            body = visit_all(cons.statements.body).map { |s| stmtify(s) }
            clauses << SyntaxTree::Go::CaseClause.new(case_: nil, list: [], colon: nil, body: body)
            cons = nil
          else
            cons = nil
          end
        end
        SyntaxTree::Go::SwitchStmt.new(switch: nil, init: nil, tag: tag, body: SyntaxTree::Go::BlockStmt.new(lbrace: nil, list: clauses, rbrace: nil))
      end

      matcher.rule(:aref_field) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ARefField)

        collection = visit(node.collection)
        index = node.index ? visit_all(node.index.parts).first : nil
        SyntaxTree::Go::IndexExpr.new(x: collection, lbrack: nil, index: index, rbrack: nil)
      end

      matcher.rule(:field_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Field)

        parent = visit(node.parent)
        name = case node.name
               when SyntaxTree::Ident, SyntaxTree::Const then node.name.value
               else node.name.to_s
               end
        selector_expr(x: parent, sel: name)
      end

      matcher.rule(:const_path_field) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ConstPathField)

        parent = visit(node.parent)
        name = node.constant.value
        selector_expr(x: parent, sel: name)
      end

      matcher.rule(:op_assign) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::OpAssign)

        target = node.target
        name = assign_target_name(target)
        op = node.operator.value rescue node.operator.to_s
        # op is like "+=" or :+
        op_str = op.to_s
        op_str = op_str + "=" unless op_str.end_with?("=")
        rhs = visit(node.value)
        SyntaxTree::Go::AssignStmt.new(
          lhs: [ident(name)],
          tok_pos: nil,
          tok: op_str,
          rhs: [rhs]
        )
      end

      matcher.rule(:while_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::WhileNode)

        cond = visit(node.predicate)
        body = visit_all(stmt_body(node.statements)).map { |s| stmtify(s) }
        SyntaxTree::Go::ForStmt.new(for_: nil, init: nil, cond: cond, post: nil, body: block_stmt(list: body))
      end

      matcher.rule(:until_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::UntilNode)

        cond = visit(node.predicate)
        cond = SyntaxTree::Go::UnaryExpr.new(op_pos: nil, op: "!".to_sym, x: SyntaxTree::Go::ParenExpr.new(lparen: nil, x: cond, rparen: nil))
        body = visit_all(stmt_body(node.statements)).map { |s| stmtify(s) }
        SyntaxTree::Go::ForStmt.new(for_: nil, init: nil, cond: cond, post: nil, body: block_stmt(list: body))
      end

      matcher.rule(:qwords) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::QWords)

        elts = node.elements.map do |e|
          case e
          when SyntaxTree::TStringContent then str_lit(e.value)
          else visit(e)
          end
        end
        SyntaxTree::Go::CompositeLit.new(
          type: SyntaxTree::Go::ArrayType.new(lbrack: nil, len: nil, elt: ident("any")),
          lbrace: nil, elts: elts, rbrace: nil, incomplete: false
        )
      end

      matcher.rule(:statements_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Statements)

        visit_all(node.body)
      end

      matcher.rule(:range_node) do |node|
        is_range = defined?(SyntaxTree::RangeNode) && node.is_a?(SyntaxTree::RangeNode)
        is_range ||= defined?(SyntaxTree::Dot2) && node.is_a?(SyntaxTree::Dot2)
        is_range ||= defined?(SyntaxTree::Dot3) && node.is_a?(SyntaxTree::Dot3)
        next Matcher::MISS unless is_range

        left = visit(node.left)
        right = visit(node.right)
        SyntaxTree::Go::CompositeLit.new(
          type: SyntaxTree::Go::ArrayType.new(lbrack: nil, len: nil, elt: ident("int")),
          lbrace: nil, elts: [left, right], rbrace: nil, incomplete: false
        )
      end

      matcher.rule(:const_path_ref) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ConstPathRef)

        left = visit(node.parent)
        right = ident(node.constant.value)
        selector_expr(x: left, sel: right)
      end

      matcher.rule(:var_ref_const) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)
        next Matcher::MISS unless node.value.is_a?(SyntaxTree::Const)

        ident(node.value.value)
      end

      matcher.rule(:unary) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Unary)

        op = node.operator.to_s
        stmt = visit(node.statement)
        SyntaxTree::Go::UnaryExpr.new(op_pos: nil, op: op.to_sym, x: stmt)
      end

      matcher.rule(:aref) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ARef)

        collection = visit(node.collection)
        index = node.index
        parts = case index
                when SyntaxTree::Args then index.parts
                else Array(index)
                end

        # slice: a[low..high] or a[low...]
        if parts.length == 1 && is_range_node?(parts.first)
          r = parts.first
          low = r.left ? visit(r.left) : ident("nil")
          high = r.right ? visit(r.right) : ident("nil")
          next SyntaxTree::Go::SliceExpr.new(x: collection, lbrack: nil, low: low, high: high, max: nil, slice3: false, rbrack: nil)
        end

        idx_nodes = visit_all(parts)
        SyntaxTree::Go::IndexExpr.new(x: collection, lbrack: nil, index: idx_nodes.first, rbrack: nil)
      end

      matcher.rule(:hash_literal) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::HashLiteral)

        assocs = node.assocs.map do |assoc|
          case assoc
          when SyntaxTree::Assoc
            key = visit(assoc.key)
            val = visit(assoc.value)
            SyntaxTree::Go::KeyValueExpr.new(key: key, colon: nil, value: val)
          else
            visit(assoc)
          end
        end
        SyntaxTree::Go::CompositeLit.new(
          type: SyntaxTree::Go::MapType.new(map: nil, key: ident("any"), value: ident("any")),
          lbrace: nil, elts: assocs, rbrace: nil, incomplete: false
        )
      end

      matcher.rule(:if_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::IfNode)

        cond = visit(node.predicate)
        cond = cond.x if cond.is_a?(SyntaxTree::Go::ParenExpr)
        consequent = visit_all(node.statements.body).map { |s| stmtify(s) }
        else_node = nil
        if node.consequent
          if node.consequent.is_a?(SyntaxTree::Elsif)
            else_node = visit(node.consequent)
          elsif node.consequent.is_a?(SyntaxTree::Else)
            else_stmts = visit_all(node.consequent.statements.body).map { |s| stmtify(s) }
            else_node = SyntaxTree::Go::BlockStmt.new(lbrace: nil, list: else_stmts, rbrace: nil)
          end
        end
        SyntaxTree::Go::IfStmt.new(if_: nil, init: nil, cond: cond, body: block_stmt(list: consequent), else_: else_node)
      end

      matcher.rule(:elsif) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Elsif)

        cond = visit(node.predicate)
        cond = cond.x if cond.is_a?(SyntaxTree::Go::ParenExpr)
        consequent = visit_all(node.statements.body).map { |s| stmtify(s) }
        else_node = nil
        if node.consequent
          if node.consequent.is_a?(SyntaxTree::Elsif)
            else_node = visit(node.consequent)
          elsif node.consequent.is_a?(SyntaxTree::Else)
            else_stmts = visit_all(node.consequent.statements.body).map { |s| stmtify(s) }
            else_node = SyntaxTree::Go::BlockStmt.new(lbrace: nil, list: else_stmts, rbrace: nil)
          end
        end
        SyntaxTree::Go::IfStmt.new(if_: nil, init: nil, cond: cond, body: block_stmt(list: consequent), else_: else_node)
      end

      matcher.rule(:unless_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::UnlessNode)

        cond = visit(node.predicate)
        cond = cond.x if cond.is_a?(SyntaxTree::Go::ParenExpr)
        consequent = visit_all(node.statements.body).map { |s| stmtify(s) }
        else_node = nil
        if node.consequent && node.consequent.is_a?(SyntaxTree::Else)
          else_stmts = visit_all(node.consequent.statements.body).map { |s| stmtify(s) }
          else_node = SyntaxTree::Go::BlockStmt.new(lbrace: nil, list: else_stmts, rbrace: nil)
        end
        # Match golden: if cond {} else { body }
        SyntaxTree::Go::IfStmt.new(
          if_: nil, init: nil, cond: cond,
          body: block_stmt(list: else_node ? else_node.list : []),
          else_: block_stmt(list: consequent)
        )
      end

      matcher.rule(:bare_assoc_hash) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::BareAssocHash)

        assocs = node.assocs.map do |assoc|
          case assoc
          when SyntaxTree::Assoc
            SyntaxTree::Go::KeyValueExpr.new(key: visit(assoc.key), colon: nil, value: visit(assoc.value))
          else
            visit(assoc)
          end
        end
        assocs
      end

      matcher.rule(:assoc_new) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Assoc)

        SyntaxTree::Go::KeyValueExpr.new(key: visit(node.key), colon: nil, value: visit(node.value))
      end

      matcher.rule(:method_add_block) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::MethodAddBlock)

        call = node.call
        block = node.block

        # defer { ... } / go { ... }
        if call.is_a?(SyntaxTree::CallNode) && call.receiver.nil? && %w[defer go].include?(call.message.value)
          stmts = scoped { visit_all(stmt_body(block.bodystmt)).map { |s| stmtify(s) } }
          fn = SyntaxTree::Go::FuncLit.new(
            type: SyntaxTree::Go::FuncType.new(func: nil, type_params: nil, params: field_list, results: nil),
            body: block_stmt(list: stmts)
          )
          call_expr_node = SyntaxTree::Go::CallExpr.new(fun: fn, lparen: nil, args: [], ellipsis: nil, rparen: nil)
          next(call.message.value == "defer" ? SyntaxTree::Go::DeferStmt.new(defer: nil, call: call_expr_node) : SyntaxTree::Go::GoStmt.new(go: nil, call: call_expr_node))
        end

        # lambda { |...| ... }
        if call.is_a?(SyntaxTree::CallNode) && call.receiver.nil? && call.message.value == "lambda"
          params = block_params(block)
          stmts = scoped(params) { visit_all(stmt_body(block.bodystmt)).map { |s| stmtify(s) } }
          fields = params.map { |n| SyntaxTree::Go::Field.new(names: [ident(n)], type: ident("any")) }
          next SyntaxTree::Go::FuncLit.new(
            type: SyntaxTree::Go::FuncType.new(func: nil, type_params: nil, params: field_list(list: fields), results: nil),
            body: block_stmt(list: stmts)
          )
        end

        # select { |c| ... }
        if call.is_a?(SyntaxTree::CallNode) && call.receiver.nil? && call.message.value == "select"
          next build_select(node, self)
        end

        # receiver.each { |...| ... } / receiver.times { |...| ... }
        if call.is_a?(SyntaxTree::CallNode) && %w[each times].include?(call.message.value)
          next build_each(node, self)
        end

        # loop { ... }
        if call.is_a?(SyntaxTree::CallNode) && call.receiver.nil? && call.message.value == "loop"
          stmts = scoped { visit_all(stmt_body(block.bodystmt)).map { |s| stmtify(s) } }
          next SyntaxTree::Go::ForStmt.new(for_: nil, init: nil, cond: nil, post: nil, body: block_stmt(list: stmts))
        end

        # Generic: call with block -> call_expr + no special handling for now
        visited_call = visit(call)
        stmts = visit_all(stmt_body(block.bodystmt)).map { |s| stmtify(s) }
        if visited_call.is_a?(SyntaxTree::Go::CallExpr)
          fn = SyntaxTree::Go::FuncLit.new(
            type: SyntaxTree::Go::FuncType.new(func: nil, type_params: nil, params: field_list, results: nil),
            body: block_stmt(list: stmts)
          )
          visited_call.args << fn
          next visited_call
        end
        Matcher::MISS
      end
    end

    # Helpers available in rule context via transpiler instance_exec
  end
end
