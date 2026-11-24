# frozen_string_literal: true

module Gob
  module Rules
    module_function

    def const_go_name(name)
      s = name.to_s
      return s unless s.match?(/\A[A-Z0-9_]+\z/)
      parts = s.split("_").reject(&:empty?)
      return s.downcase if parts.length <= 1
      parts.first.downcase + parts.drop(1).map { |p| p.capitalize }.join
    end

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

      matcher.rule(:begin_block) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Begin)
        bs = node.bodystmt
        if bs.is_a?(SyntaxTree::BodyStmt)
          next Matcher::MISS if bs.rescue_clause || bs.else_clause || bs.ensure_clause
        end
        stmts = visit_all(stmt_body(bs)).map { |s| stmtify(s) }
        SyntaxTree::Go::BlockStmt.new(lbrace: nil, list: stmts, rbrace: nil)
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
        next Matcher::MISS if %w[define_const define_var].include?(name)

        args = visit_args(node.arguments)
        call_expr(fun: ident(name), args: args)
      end

      matcher.rule(:define_const) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Command)
        next Matcher::MISS unless node.message.is_a?(SyntaxTree::Ident) && node.message.value == "define_const"

        parts = node.arguments.is_a?(SyntaxTree::Args) ? node.arguments.parts : Array(node.arguments)
        name_node = parts[0]
        value_node = parts[1]
        next Matcher::MISS unless name_node && value_node

        name = case name_node
               when SyntaxTree::SymbolLiteral then name_node.value.value.to_s
               when SyntaxTree::Ident then name_node.value
               when SyntaxTree::StringLiteral then string_value(name_node)
               else name_node.to_s
               end
        go_name = Gob::Rules.const_go_name(name)
        val = visit(value_node)
        decl = SyntaxTree::Go::GenDecl.new(
          doc: nil, tok_pos: nil, tok: "const", lparen: nil,
          specs: [SyntaxTree::Go::ValueSpec.new(doc: nil, names: [ident(go_name)], type: nil, values: [val], comment: nil)],
          rparen: nil
        )
        decl.instance_variable_set(:@location, node.location) rescue nil
        decl
      end

      matcher.rule(:define_var) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Command)
        next Matcher::MISS unless node.message.is_a?(SyntaxTree::Ident) && node.message.value == "define_var"

        parts = node.arguments.is_a?(SyntaxTree::Args) ? node.arguments.parts : Array(node.arguments)
        name_node = parts[0]
        type_node = parts[1]
        value_node = parts[2]
        next Matcher::MISS unless name_node && type_node

        name = case name_node
               when SyntaxTree::SymbolLiteral then name_node.value.value.to_s
               when SyntaxTree::Ident then name_node.value
               when SyntaxTree::StringLiteral then string_value(name_node)
               else name_node.to_s
               end
        type_name = case type_node
                    when SyntaxTree::SymbolLiteral then type_node.value.value.to_s
                    when SyntaxTree::Ident then type_node.value
                    when SyntaxTree::StringLiteral then string_value(type_node)
                    else type_node.to_s
                    end
        val = value_node ? visit(value_node) : nil
        spec = SyntaxTree::Go::ValueSpec.new(
          doc: nil, names: [ident(name)], type: ident(type_name), values: val ? [val] : [], comment: nil
        )
        decl = SyntaxTree::Go::GenDecl.new(doc: nil, tok_pos: nil, tok: "var", lparen: nil, specs: [spec], rparen: nil)
        decl.instance_variable_set(:@location, node.location) rescue nil
        decl
      end

      matcher.rule(:define_const_call) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)
        next Matcher::MISS unless node.receiver.nil?
        msg = node.message
        name_str = msg.is_a?(SyntaxTree::Ident) ? msg.value : msg.to_s
        next Matcher::MISS unless name_str == "define_const"

        parts = if node.arguments.is_a?(SyntaxTree::ArgParen)
                  node.arguments.arguments.is_a?(SyntaxTree::Args) ? node.arguments.arguments.parts : Array(node.arguments.arguments)
                elsif node.arguments.is_a?(SyntaxTree::Args)
                  node.arguments.parts
                else
                  Array(node.arguments)
                end
        name_node = parts[0]
        value_node = parts[1]
        next Matcher::MISS unless name_node && value_node

        name = case name_node
               when SyntaxTree::SymbolLiteral then name_node.value.value.to_s
               when SyntaxTree::Ident then name_node.value
               when SyntaxTree::StringLiteral then string_value(name_node)
               else name_node.to_s
               end
        go_name = Gob::Rules.const_go_name(name)
        val = visit(value_node)
        decl = SyntaxTree::Go::GenDecl.new(
          doc: nil, tok_pos: nil, tok: "const", lparen: nil,
          specs: [SyntaxTree::Go::ValueSpec.new(doc: nil, names: [ident(go_name)], type: nil, values: [val], comment: nil)],
          rparen: nil
        )
        decl.instance_variable_set(:@location, node.location) rescue nil
        decl
      end

      matcher.rule(:define_var_call) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)
        next Matcher::MISS unless node.receiver.nil?
        msg = node.message
        name_str = msg.is_a?(SyntaxTree::Ident) ? msg.value : msg.to_s
        next Matcher::MISS unless name_str == "define_var"

        parts = if node.arguments.is_a?(SyntaxTree::ArgParen)
                  node.arguments.arguments.is_a?(SyntaxTree::Args) ? node.arguments.arguments.parts : Array(node.arguments.arguments)
                elsif node.arguments.is_a?(SyntaxTree::Args)
                  node.arguments.parts
                else
                  Array(node.arguments)
                end
        name_node = parts[0]
        type_node = parts[1]
        value_node = parts[2]
        next Matcher::MISS unless name_node && type_node

        name = case name_node
               when SyntaxTree::SymbolLiteral then name_node.value.value.to_s
               when SyntaxTree::Ident then name_node.value
               when SyntaxTree::StringLiteral then string_value(name_node)
               else name_node.to_s
               end
        type_name = case type_node
                    when SyntaxTree::SymbolLiteral then type_node.value.value.to_s
                    when SyntaxTree::Ident then type_node.value
                    when SyntaxTree::StringLiteral then string_value(type_node)
                    else type_node.to_s
                    end
        val = value_node ? visit(value_node) : nil
        spec = SyntaxTree::Go::ValueSpec.new(
          doc: nil, names: [ident(name)], type: ident(type_name), values: val ? [val] : [], comment: nil
        )
        decl = SyntaxTree::Go::GenDecl.new(doc: nil, tok_pos: nil, tok: "var", lparen: nil, specs: [spec], rparen: nil)
        decl.instance_variable_set(:@location, node.location) rescue nil
        decl
      end

      matcher.rule(:class_decl) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::ClassDeclaration)

        class_name = const_name(node.constant)
        body = stmt_body(node.bodystmt)
        fields = []
        decls = []

        body.each do |stmt|
          # attr_accessor :Name, :type # `tag`
          if stmt.is_a?(SyntaxTree::Command) && stmt.message.is_a?(SyntaxTree::Ident) && stmt.message.value == "attr_accessor"
            parts = stmt.arguments.is_a?(SyntaxTree::Args) ? stmt.arguments.parts : Array(stmt.arguments)
            name_node = parts[0]
            type_node = parts[1]
            next unless name_node

            field_name = case name_node
                         when SyntaxTree::SymbolLiteral then name_node.value.value.to_s
                         when SyntaxTree::Ident then name_node.value
                         when SyntaxTree::StringLiteral then string_value(name_node)
                         else name_node.to_s
                         end

            # tag from trailing comment
            tag = nil
            if stmt.respond_to?(:comments)
              stmt.comments.each do |c|
                t = c.value.to_s.strip.sub(/^#\s*/, "")
                tag = t if t.start_with?("`") && t.end_with?("`")
              end
            end
            # also check inline comments on parts
            if !tag
              Array(parts).each do |p|
                next unless p.respond_to?(:comments)
                p.comments.each do |c|
                  t = c.value.to_s.strip.sub(/^#\s*/, "")
                  tag = t if t.start_with?("`") && t.end_with?("`")
                end
              end
            end

            if type_node.nil?
              # embedding: attr_accessor :User
              fields << SyntaxTree::Go::Field.new(
                doc: nil, names: [], type: ident(field_name), tag: tag ? SyntaxTree::Go::BasicLit.new(kind: "STRING", value: tag) : nil, comment: nil
              )
            else
              type_name = case type_node
                          when SyntaxTree::SymbolLiteral then type_node.value.value.to_s
                          when SyntaxTree::Ident then type_node.value
                          when SyntaxTree::StringLiteral then string_value(type_node)
                          else type_node.to_s
                          end
              tag_lit = tag ? SyntaxTree::Go::BasicLit.new(kind: "STRING", value: tag) : nil
              fields << SyntaxTree::Go::Field.new(
                doc: nil, names: [ident(field_name)], type: parse_go_type(type_name), tag: tag_lit, comment: nil
              )
            end
            next
          end

          if stmt.is_a?(SyntaxTree::DefNode)
            method_name = stmt.name.value
            param_names = param_name_list(stmt.params)
            sig = signature_for_def(stmt)

            if method_name == "initialize"
              # constructor: func NewClassName(...) *ClassName
              body_stmts = with_class_self(class_name) do
                scoped(param_names) do
                  visit_all(stmt_body(stmt.bodystmt)).map { |s| stmtify(s) }
                end
              end
              # replace self = &ClassName{}? We'll build it: self := &ClassName{} at start, return self at end
              init_self = SyntaxTree::Go::AssignStmt.new(
                lhs: [ident("self")], tok: ":=", rhs: [
                  SyntaxTree::Go::UnaryExpr.new(op: "&", x: SyntaxTree::Go::CompositeLit.new(
                    type: ident(class_name), lbrace: nil, elts: [], rbrace: nil, incomplete: false
                  ))
                ]
              )
              ret_self = SyntaxTree::Go::ReturnStmt.new(return_: nil, results: [ident("self")])
              ctor_body = [init_self] + body_stmts + [ret_self]
              params = param_names.each_with_index.map do |n, i|
                t = sig && sig[:params][i] ? parse_go_type(sig[:params][i]) : nil
                SyntaxTree::Go::Field.new(names: [ident(n)], type: t)
              end
              decls << func_decl(
                name: "New#{class_name}",
                params: params,
                body: ctor_body,
                results: field_list(list: [SyntaxTree::Go::Field.new(names: [], type: SyntaxTree::Go::StarExpr.new(star: nil, x: ident(class_name)))])
              )
              next
            end

            body_stmts = with_class_self(class_name) do
              scoped(param_names) do
                visit_all(stmt_body(stmt.bodystmt)).map { |s| stmtify(s) }
              end
            end
            params = param_names.each_with_index.map do |n, i|
              t = sig && sig[:params][i] ? parse_go_type(sig[:params][i]) : nil
              SyntaxTree::Go::Field.new(names: [ident(n)], type: t)
            end
            results = if sig && sig[:returns] && !sig[:returns].empty?
                        field_list(list: sig[:returns].map { |r| SyntaxTree::Go::Field.new(names: [], type: parse_go_type(r)) })
                      else
                        nil
                      end
            recv = field_list(list: [SyntaxTree::Go::Field.new(names: [ident("self")], type: SyntaxTree::Go::StarExpr.new(star: nil, x: ident(class_name)))])
            decls << func_decl(name: method_name, params: params, body: body_stmts, results: results, recv: recv)
            next
          end

          # other statements: define_const/define_var handled by normal rules if visited
          visited = visit(stmt)
          next if visited.nil?
          Array(visited).each do |v|
            decls << v if v
          end
        end

        struct_type = SyntaxTree::Go::StructType.new(struct: nil, fields: field_list(list: fields), incomplete: false)
        type_spec = SyntaxTree::Go::TypeSpec.new(doc: nil, name: ident(class_name), type_params: nil, assign: nil, type: struct_type, comment: nil)
        type_decl = SyntaxTree::Go::GenDecl.new(doc: nil, tok_pos: nil, tok: "type", lparen: nil, specs: [type_spec], rparen: nil)

        [type_decl] + decls
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
        sig = signature_for_def(node)

        body_stmts = scoped(param_names) do
          visit_all(stmt_body(node.bodystmt)).map { |s| stmtify(s) }
        end

        params = param_names.each_with_index.map do |n, i|
          t = sig && sig[:params][i] ? parse_go_type(sig[:params][i]) : nil
          SyntaxTree::Go::Field.new(names: [ident(n)], type: t)
        end

        results = if sig && sig[:returns] && !sig[:returns].empty?
                    field_list(list: sig[:returns].map { |r| SyntaxTree::Go::Field.new(names: [], type: parse_go_type(r)) })
                  else
                    nil
                  end

        func_decl(name: name, params: params, body: body_stmts, results: results)
      end

      matcher.rule(:call_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

        receiver = visit(node.receiver)
        msg = node.message
        msg_name = msg.is_a?(SyntaxTree::Const) ? msg.value : msg.value
        next Matcher::MISS if receiver.nil? && %w[define_const define_var].include?(msg_name.to_s)

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

      matcher.rule(:var_ref_ivar) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)
        next Matcher::MISS unless node.value.is_a?(SyntaxTree::IVar)

        selector_expr(x: ident("self"), sel: node.value.value.delete_prefix("@"))
      end

      matcher.rule(:ivar) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::IVar)

        selector_expr(x: ident("self"), sel: node.value.delete_prefix("@"))
      end

      matcher.rule(:field_node) do |node|
        next Matcher::MISS unless node.is_a?(SyntaxTree::Field)

        receiver = visit(node.parent)
        name = node.name.is_a?(SyntaxTree::Ident) ? node.name.value : node.name.to_s
        selector_expr(x: receiver, sel: name)
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

        t = node.target
        if (t.is_a?(SyntaxTree::VarField) && t.value.is_a?(SyntaxTree::Const)) ||
           t.is_a?(SyntaxTree::ConstRef)
          name = assign_target_name(t, self)
          val = visit(node.value)
          decl = SyntaxTree::Go::GenDecl.new(
            doc: nil, tok_pos: nil, tok: "const", lparen: nil,
            specs: [SyntaxTree::Go::ValueSpec.new(doc: nil, names: [ident(Gob::Rules.const_go_name(name.to_s))], type: nil, values: [val], comment: nil)],
            rparen: nil
          )
          decl.instance_variable_set(:@location, node.location) rescue nil
          next decl
        end

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
        if inner.is_a?(SyntaxTree::Params)
          next Matcher::MISS
        end
        visited = visit(inner)
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

        ident(Gob::Rules.const_go_name(node.constant.value))
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
                list: [SyntaxTree::Go::Field.new(names: [ident("self")], type: SyntaxTree::Go::StarExpr.new(star: nil, x: ident(name)))],
                closing: nil
              )
              visited = SyntaxTree::Go::FuncDecl.new(
                doc: visited.doc, recv: recv, name: visited.name, type: visited.type, body: visited.body
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
        str_lit(name)
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

        ident(Gob::Rules.const_go_name(node.value.value))
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
        idx_nodes = case index
                    when SyntaxTree::Args then visit_all(index.parts)
                    else visit_all(Array(index))
                    end
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
        cond = SyntaxTree::Go::UnaryExpr.new(op_pos: nil, op: "!".to_sym, x: SyntaxTree::Go::ParenExpr.new(lparen: nil, x: cond, rparen: nil))
        consequent = visit_all(node.statements.body).map { |s| stmtify(s) }
        else_node = nil
        if node.consequent
          if node.consequent.is_a?(SyntaxTree::Else)
            else_stmts = visit_all(node.consequent.statements.body).map { |s| stmtify(s) }
            else_node = SyntaxTree::Go::BlockStmt.new(lbrace: nil, list: else_stmts, rbrace: nil)
          end
        end
        SyntaxTree::Go::IfStmt.new(if_: nil, init: nil, cond: cond, body: block_stmt(list: consequent), else_: else_node)
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
          stmts = visit_all(stmt_body(block.bodystmt)).map { |s| stmtify(s) }
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
          fields = params.map { |n| SyntaxTree::Go::Field.new(names: [ident(n)], type: nil) }
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
