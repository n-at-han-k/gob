# frozen_string_literal: true

module SyntaxTree
  module Go
    # Provides PascalCase shortcuts for constructing Go AST nodes.
    module DSL
      def Ident(name)
        SyntaxTree::Go::Ident.new(name: name.to_s)
      end

      def BasicLit(kind, value)
        SyntaxTree::Go::BasicLit.new(kind: kind.to_sym, value: value.to_s)
      end

      def CharLiteral(value)
        BasicLit(:CHAR, "'#{value}'")
      end

      def StringLiteral(value)
        BasicLit(:STRING, "\"#{value}\"")
      end

      def RawStringLiteral(value)
        BasicLit(:STRING, "`#{value}`")
      end

      def IntLiteral(value)
        BasicLit(:INT, value)
      end

      def FloatLiteral(value)
        BasicLit(:FLOAT, value)
      end

      def PointerType(node, context:)
        case node
        in SyntaxTree::CallNode[
             receiver: SyntaxTree::VarRef[
               value: SyntaxTree::IVar | SyntaxTree::CVar
             ],
             operator: SyntaxTree::Period[value: "."],
             message: SyntaxTree::Const,
             arguments: nil
           ]
          StarExpr(GoType(node, context: context))
        else
          GoType(node, context: context)
        end
      end

      def GoType(node, context:)
        case node
        in SyntaxTree::VCall[value: SyntaxTree::Ident[value: "Proc"]]
          FuncType([], nil)
        in SyntaxTree::VCall[value: SyntaxTree::Ident[value: name]]
          Ident(name)
        in SyntaxTree::SymbolLiteral[value: value]
          name =
            case value
            in SyntaxTree::Ident[value: identifier]
              identifier
            in SyntaxTree::Const[value: constant]
              constant
            end
          Ident(name)
        in SyntaxTree::VarRef[value: SyntaxTree::Const[value: "Proc"]]
          FuncType([], nil)
        in SyntaxTree::VarRef[value: SyntaxTree::Const[value: name]]
          Ident(Gob::Transpilation::Rules.const_go_name(name))
        in SyntaxTree::CallNode[
             receiver: nil,
             operator: nil,
             message: SyntaxTree::Ident[value: "ptr" | "ref"],
             arguments: SyntaxTree::ArgParen[
               arguments: SyntaxTree::Args[parts: [type]]
             ]
           ]
          StarExpr(GoType(type, context: context))
        in SyntaxTree::CallNode[
             receiver: receiver,
             operator: SyntaxTree::Period[value: "."],
             message: SyntaxTree::Const[value: name],
             arguments: nil
           ]
          package_name =
            case receiver
            in SyntaxTree::VCall[value: SyntaxTree::Ident[value: identifier]]
              identifier
            in SyntaxTree::VarRef[value: SyntaxTree::IVar[value: ivar]]
              ivar.delete_prefix("@")
            in SyntaxTree::VarRef[value: SyntaxTree::CVar[value: cvar]]
              cvar.delete_prefix("@@")
            in SyntaxTree::VarRef[value: SyntaxTree::Const[value: constant]]
              constant
            end
          SelectorExpr(Ident(package_name), name)
        in SyntaxTree::ARef[
             collection: SyntaxTree::VarRef[
               value: SyntaxTree::Const[value: "Array"]
             ],
             index: SyntaxTree::Args[parts: [element]]
           ]
          ArrayType(PointerType(element, context: context))
        in SyntaxTree::ARef[
             collection: SyntaxTree::VarRef[
               value: SyntaxTree::Const[value: "Hash" | "Map"]
             ],
             index: SyntaxTree::Args[parts: [key, value]]
           ]
          MapType(
            PointerType(key, context: context),
            PointerType(value, context: context)
          )
        in SyntaxTree::IVar[value: value]
          StarExpr(Ident(value.delete_prefix("@")))
        in SyntaxTree::CVar[value: value]
          Ident(value.delete_prefix("@@"))
        else
          context.visit(node)
        end
      end

      def StructLiteral(receiver, arguments, context:)
        pointer =
          case receiver
          in SyntaxTree::CallNode[
               receiver: SyntaxTree::VarRef[value: SyntaxTree::IVar],
               operator: SyntaxTree::Period[value: "."],
               message: SyntaxTree::Const,
               arguments: nil
             ]
            true
          in SyntaxTree::VarRef[value: SyntaxTree::IVar]
            true
          else
            false
          end
        type =
          case receiver
          in SyntaxTree::VarRef[value: SyntaxTree::IVar[value: name]]
            Ident(
              Gob::Transpilation::Rules.const_go_name(name.delete_prefix("@"))
            )
          else
            GoType(receiver, context: context)
          end
        parts =
          case arguments
          in SyntaxTree::ArgParen[arguments: SyntaxTree::Args[parts: parts]]
            parts
          in SyntaxTree::ArgParen[arguments: nil]
            []
          in SyntaxTree::Args[parts: parts]
            parts
          else
            Array(arguments)
          end
        elements =
          parts.flat_map do |part|
            case part
            in SyntaxTree::BareAssocHash[assocs: assocs]
              assocs.map do |assoc|
                case assoc
                in SyntaxTree::Assoc[
                     key: SyntaxTree::Label[value: label], value: value
                   ]
                  key =
                    if type.is_a?(SyntaxTree::Go::MapType)
                      StringLiteral(label.chomp(":"))
                    else
                      Ident(label.chomp(":"))
                    end
                  KeyValueExpr(key, context.visit(value))
                end
              end
            else
              context.visit(part)
            end
          end
        if type.is_a?(SyntaxTree::Go::ArrayType) &&
             type.elt.is_a?(SyntaxTree::Go::Ident) && type.elt.name == "byte" &&
             elements.length == 1 &&
             elements.first.is_a?(SyntaxTree::Go::BasicLit) &&
             elements.first.kind.to_s == "STRING"
          return CallExpr(type, elements)
        end

        literal = CompositeLit(type, elements)
        if parts.any? { |part|
             part.is_a?(SyntaxTree::BareAssocHash) &&
               part.location.start_line != part.location.end_line
           }
          literal.instance_variable_set(:@multiline, true)
        end
        pointer ? UnaryExpr(:&, literal) : literal
      end

      def Each(receiver, params, body, context:)
        names =
          Array(params).map do |param|
            case param
            in SyntaxTree::Ident[value: name]
              name
            end
          end
        statements =
          context.scoped(names) do
            context
              .visit_all(body)
              .map { |statement| context.stmtify(statement) }
          end
        key = names[0] == "_" ? nil : Ident(names[0])
        value = names[1] == "_" ? nil : Ident(names[1])

        RangeStmt(
          context.visit(receiver),
          key: key,
          value: value,
          body: BlockStmt(statements)
        )
      end

      def ArrayType(elt, len = nil)
        SyntaxTree::Go::ArrayType.new(lbrack: nil, len: len, elt: elt)
      end

      def MapType(key, value)
        SyntaxTree::Go::MapType.new(map: nil, key: key, value: value)
      end

      def StarExpr(x)
        SyntaxTree::Go::StarExpr.new(star: nil, x: x)
      end

      def SelectorExpr(x, sel)
        SyntaxTree::Go::SelectorExpr.new(
          x: x,
          sel: sel.is_a?(String) || sel.is_a?(Symbol) ? Ident(sel) : sel
        )
      end

      def CallExpr(fun, args = [])
        SyntaxTree::Go::CallExpr.new(
          fun: fun,
          lparen: nil,
          args: Array(args),
          ellipsis: nil,
          rparen: nil
        )
      end

      def IndexExpr(x, index)
        SyntaxTree::Go::IndexExpr.new(
          x: x,
          lbrack: nil,
          index: index,
          rbrack: nil
        )
      end

      def SliceExpr(x, low: nil, high: nil, max: nil, slice3: false)
        SyntaxTree::Go::SliceExpr.new(
          x: x,
          lbrack: nil,
          low: low,
          high: high,
          max: max,
          slice3: slice3,
          rbrack: nil
        )
      end

      def IncDecStmt(x, tok)
        SyntaxTree::Go::IncDecStmt.new(x: x, tok_pos: nil, tok: tok)
      end

      def ExprStmt(x)
        SyntaxTree::Go::ExprStmt.new(x: x)
      end

      def AssignStmt(lhs, tok, rhs)
        SyntaxTree::Go::AssignStmt.new(
          lhs: Array(lhs),
          tok_pos: nil,
          tok: tok,
          rhs: Array(rhs)
        )
      end

      def Assignment(name, value, context:)
        if context.package_scope?
          GenDecl(:var, [ValueSpec([name], values: [value])])
        else
          LocalAssignment([name], [value], context: context)
        end
      end

      def LocalAssignment(names, values, context:)
        names = Array(names)
        values = Array(values)
        scope = context.current_scope
        fresh = names.any? { |name| name != "_" && !scope.include?(name) }
        names.each { |name| scope << name unless name == "_" }

        AssignStmt(names.map { |name| Ident(name) }, fresh ? ":=" : "=", values)
      end

      def ReturnStmt(results = [])
        SyntaxTree::Go::ReturnStmt.new(return_: nil, results: Array(results))
      end

      def Field(names, type = nil, tag: nil)
        SyntaxTree::Go::Field.new(
          doc: nil,
          names:
            Array(names).map do |name|
              name.is_a?(String) || name.is_a?(Symbol) ? Ident(name) : name
            end,
          type: type,
          tag: tag,
          comment: nil
        )
      end

      def FieldList(fields = [])
        SyntaxTree::Go::FieldList.new(
          opening: nil,
          list: Array(fields),
          closing: nil
        )
      end

      def FuncType(params = nil, results = nil)
        SyntaxTree::Go::FuncType.new(
          func: nil,
          type_params: nil,
          params:
            (
              if params.is_a?(SyntaxTree::Go::FieldList)
                params
              else
                FieldList(params)
              end
            ),
          results: results
        )
      end

      def FuncDecl(name, params: nil, results: nil, body: nil, recv: nil)
        SyntaxTree::Go::FuncDecl.new(
          doc: nil,
          recv: recv,
          name: name.is_a?(String) || name.is_a?(Symbol) ? Ident(name) : name,
          type: FuncType(params, results),
          body: body
        )
      end

      def FuncLit(type:, body:)
        SyntaxTree::Go::FuncLit.new(type: type, body: body)
      end

      def FunctionName(node)
        case node
        in SyntaxTree::Ident[value: name]
          name
        in SyntaxTree::Const[value: name]
          name
        end
      end

      def ParameterNodes(params)
        case params
        in SyntaxTree::Params[requireds: requireds]
          Array(requireds)
        in SyntaxTree::Paren[contents: SyntaxTree::Params[requireds: requireds]]
          Array(requireds)
        else
          []
        end
      end

      def ParameterNames(parameters)
        Array(parameters).map do |parameter|
          case parameter
          in SyntaxTree::Ident[value: name]
            name
          end
        end
      end

      def Signature(text, context:)
        context.parse_signature_comment(text)
      end

      def Function(
        name,
        parameter_names:,
        parameter_types:,
        return_types:,
        body:,
        recv: nil,
        context:
      )
        fields =
          parameter_names.each_with_index.map do |parameter_name, index|
            Field(
              [parameter_name],
              context.parse_go_type(parameter_types[index] || "any")
            )
          end
        results =
          if return_types.empty?
            nil
          else
            FieldList(
              return_types.map { |type| Field([], context.parse_go_type(type)) }
            )
          end

        FuncDecl(
          name,
          recv: recv,
          params: fields,
          results: results,
          body:
            BlockStmt(
              context.scoped(parameter_names) do
                context
                  .visit_all(body)
                  .map { |statement| context.stmtify(statement) }
              end
            )
        )
      end

      def UnsignedFunction(name_node, params, body, context:, recv: nil)
        parameter_names = ParameterNames(ParameterNodes(params))

        Function(
          FunctionName(name_node),
          parameter_names: parameter_names,
          parameter_types: Array.new(parameter_names.length, "any"),
          return_types: [],
          body: body,
          recv: recv,
          context: context
        )
      end

      def SignedFunction(
        name_node,
        params,
        signature_text,
        body,
        context:,
        recv: nil
      )
        parameter_names = ParameterNames(ParameterNodes(params))
        signature = Signature(signature_text, context: context)

        Function(
          FunctionName(name_node),
          parameter_names: parameter_names,
          parameter_types: signature[:params],
          return_types: signature[:returns],
          body: body,
          recv: recv,
          context: context
        )
      end

      def ReturnsOnlyFunction(name_node, signature_text, body, context:)
        signature = Signature(signature_text, context: context)

        Function(
          FunctionName(name_node),
          parameter_names: [],
          parameter_types: [],
          return_types: signature[:returns],
          body: body,
          context: context
        )
      end

      def PointerReceiver?(node)
        case node
        when Array
          node.any? { |child| PointerReceiver?(child) }
        when SyntaxTree::IVar
          true
        when SyntaxTree::VarRef
          node.value.is_a?(SyntaxTree::IVar)
        when SyntaxTree::Node
          node.child_nodes.any? { |child| PointerReceiver?(child) }
        else
          false
        end
      end

      def UsesSelf?(node)
        case node
        when Array
          node.any? { |child| UsesSelf?(child) }
        when SyntaxTree::IVar
          node.value == "@self"
        when SyntaxTree::VarRef
          (node.value.is_a?(SyntaxTree::Kw) && node.value.value == "self") ||
            UsesSelf?(node.value)
        when SyntaxTree::Node
          node.child_nodes.any? { |child| UsesSelf?(child) }
        else
          false
        end
      end

      def MethodReceiver(context:, pointer:, named:)
        type =
          Ident(Gob::Transpilation::Rules.const_go_name(context.current_class))
        type = StarExpr(type) if pointer

        FieldList([Field(named ? ["self"] : [], type)])
      end

      def Method(name_node, params, signature_text, body, context:)
        SignedFunction(
          name_node,
          params,
          signature_text,
          body,
          context: context,
          recv:
            MethodReceiver(
              context: context,
              pointer: PointerReceiver?(body),
              named: UsesSelf?(body)
            )
        )
      end

      def MethodReturnsOnly(name_node, signature_text, body, context:)
        signature = Signature(signature_text, context: context)

        Function(
          FunctionName(name_node),
          parameter_names: [],
          parameter_types: [],
          return_types: signature[:returns],
          body: body,
          recv:
            MethodReceiver(
              context: context,
              pointer: PointerReceiver?(body),
              named: UsesSelf?(body)
            ),
          context: context
        )
      end

      def BlockParameters(block_var)
        case block_var
        in SyntaxTree::BlockVar[params: params]
          params
        else
          nil
        end
      end

      def BodyStatements(node)
        case node
        in SyntaxTree::BodyStmt[statements: SyntaxTree::Statements[body: body]]
          body
        in SyntaxTree::Statements[body: body]
          body
        else
          Array(node)
        end
      end

      def Lambda(block_var, body, context:)
        params = BlockParameters(block_var)
        parameter_names = ParameterNames(ParameterNodes(params))
        signature_text =
          context
            .collect_comments(block_var)
            .map(&:value)
            .find { |comment| context.parse_signature_comment(comment) }
        signature =
          signature_text && Signature(signature_text, context: context)
        parameter_types = signature ? signature[:params] : []
        return_types = signature ? signature[:returns] : []
        fields =
          parameter_names.each_with_index.map do |parameter_name, index|
            Field(
              [parameter_name],
              context.parse_go_type(parameter_types[index] || "any")
            )
          end
        results =
          if return_types.empty?
            nil
          else
            FieldList(
              return_types.map { |type| Field([], context.parse_go_type(type)) }
            )
          end

        FuncLit(
          type: FuncType(fields, results),
          body:
            BlockStmt(
              context.scoped(parameter_names) do
                context
                  .visit_all(body)
                  .map { |statement| context.stmtify(statement) }
              end
            )
        )
      end

      def StructTag(assoc, type)
        comment =
          assoc.comments.map(&:value).find { |value| value.match?(/`[^`]+`/) }
        return nil unless comment

        tag = comment[/`([^`]+)`/, 1]
        name, options = tag.split(":", 2)
        values =
          options.to_s.sub(/\A"/, "").sub(/"\z/, "").split(",").reject(&:empty?)
        reference =
          type.is_a?(SyntaxTree::Go::ArrayType) ||
            type.is_a?(SyntaxTree::Go::MapType) ||
            type.is_a?(SyntaxTree::Go::StarExpr)

        if reference && !values.include?("omitempty")
          values << "omitempty"
        elsif !reference
          values.delete("omitempty")
        end

        BasicLit(:STRING, "`#{name}:\"#{values.join(",")}\"`")
      end

      def StructNew(name, assocs, context:)
        fields =
          assocs.map do |assoc|
            case assoc
            in SyntaxTree::Assoc[
                 key: SyntaxTree::Label[value: label], value: type
               ]
              type = GoType(type, context: context)
              [label.chomp(":"), type, StructTag(assoc, type)]
            end
          end

        GenDecl(
          :type,
          [
            TypeSpec(
              Gob::Transpilation::Rules.const_go_name(name),
              Struct(fields)
            )
          ]
        )
      end

      def StructNewWithBlock(name, arguments, body, context:)
        fields =
          case arguments.first
          in SyntaxTree::BareAssocHash[assocs: assocs]
            assocs.map do |assoc|
              case assoc
              in SyntaxTree::Assoc[
                   key: SyntaxTree::Label[value: label], value: type
                 ]
                type = GoType(type, context: context)
                [label.chomp(":"), type, StructTag(assoc, type)]
              end
            end
          else
            arguments.filter_map do |argument|
              case argument
              in SyntaxTree::SymbolLiteral[
                   value: SyntaxTree::Const[value: field_name]
                 ]
                [field_name, nil]
              end
            end
          end
        type_decl =
          GenDecl(
            :type,
            [
              TypeSpec(
                Gob::Transpilation::Rules.const_go_name(name),
                Struct(fields)
              )
            ]
          )
        methods = []

        context.with_class_self(name) do
          body.each do |child|
            if child.is_a?(SyntaxTree::DefNode)
              methods.concat(Array(context.visit(child)))
            end
          end
        end

        [type_decl, *methods]
      end

      def ProcType(parameters, returns, context:)
        params =
          Array(parameters).map do |parameter|
            Field([], GoType(parameter, context: context))
          end
        results =
          if returns
            FieldList(
              Array(returns).map do |type|
                Field([], GoType(type, context: context))
              end
            )
          end

        FuncType(params, results)
      end

      def StructNewFromNames(name, names)
        fields = names.map { |field_name| [field_name, nil] }

        GenDecl(
          :type,
          [
            TypeSpec(
              Gob::Transpilation::Rules.const_go_name(name),
              Struct(fields)
            )
          ]
        )
      end

      def FieldName(symbol)
        case symbol
        in SyntaxTree::Const[value: name]
          name
        in SyntaxTree::Ident[value: name]
          name
        end
      end

      def StructDefinition(name, body, context:)
        fields = []
        methods = []

        context.with_class_self(name) do
          body.each do |child|
            case child
            in SyntaxTree::Command[
                 message: SyntaxTree::Ident[value: "attr_accessor"],
                 arguments: SyntaxTree::Args[
                   parts: [SyntaxTree::SymbolLiteral[value: symbol], type]
                 ]
               ]
              fields << [FieldName(symbol), GoType(type, context: context)]
            in SyntaxTree::Command[
                 message: SyntaxTree::Ident[value: "attr_accessor"],
                 arguments: SyntaxTree::Args[
                   parts: [SyntaxTree::SymbolLiteral[value: symbol]]
                 ]
               ]
              fields << [FieldName(symbol), nil]
            in SyntaxTree::DefNode
              methods.concat(Array(context.visit(child)))
            in SyntaxTree::VoidStmt
              next
            else
              methods.concat(Array(context.visit(child)))
            end
          end
        end

        [
          GenDecl(
            :type,
            [
              TypeSpec(
                Gob::Transpilation::Rules.const_go_name(name),
                Struct(fields)
              )
            ]
          ),
          *methods
        ]
      end

      def BlockStmt(statements = [])
        SyntaxTree::Go::BlockStmt.new(
          lbrace: nil,
          list: Array(statements),
          rbrace: nil
        )
      end

      def DeclStmt(decl)
        SyntaxTree::Go::DeclStmt.new(decl: decl)
      end

      def GenDecl(tok, specs = [])
        SyntaxTree::Go::GenDecl.new(
          doc: nil,
          tok_pos: nil,
          tok: tok.to_sym,
          lparen: nil,
          specs: Array(specs),
          rparen: nil
        )
      end

      def ImportSpec(path, name: nil)
        SyntaxTree::Go::ImportSpec.new(
          doc: nil,
          name: name,
          path: path.is_a?(String) ? StringLiteral(path) : path,
          comment: nil,
          end_pos: nil
        )
      end

      def VarDeclaration(name, type, values, context:)
        context.declare(name)

        GenDecl(:var, [ValueSpec([name], type, values: values)])
      end

      def ConstDeclaration(name, value, context:)
        context.declare(name)

        GenDecl(:const, [ValueSpec([name], values: [value])])
      end

      def ValueSpec(names, type = nil, values: [])
        SyntaxTree::Go::ValueSpec.new(
          doc: nil,
          names:
            Array(names).map do |name|
              name.is_a?(String) || name.is_a?(Symbol) ? Ident(name) : name
            end,
          type: type,
          values: Array(values),
          comment: nil
        )
      end

      def TypeSpec(name, type, type_params: nil)
        SyntaxTree::Go::TypeSpec.new(
          doc: nil,
          name: name.is_a?(String) || name.is_a?(Symbol) ? Ident(name) : name,
          type_params: type_params,
          assign: nil,
          type: type,
          comment: nil
        )
      end

      def Struct(fields)
        entries = Array(fields).map { |name, type, tag| [name, type, tag] }
        entries =
          entries.map.with_index do |(name, type, tag), index|
            inferred =
              type ||
                entries[(index + 1)..]
                  .find { |_name, candidate, _tag| candidate }
                  &.[](1) || Ident("any")
            [name, inferred, tag]
          end

        grouped = []
        entries.each do |name, type, tag|
          if grouped.last && grouped.last[1] === type && grouped.last[2] === tag
            grouped.last.first << name
          else
            grouped << [[name], type, tag]
          end
        end

        StructType(
          grouped.map { |names, type, tag| Field(names, type, tag: tag) }
        )
      end

      def StructType(fields, incomplete: false)
        SyntaxTree::Go::StructType.new(
          struct: nil,
          fields:
            (
              if fields.is_a?(SyntaxTree::Go::FieldList)
                fields
              else
                FieldList(fields)
              end
            ),
          incomplete: incomplete
        )
      end

      def BinaryExpr(x, op, y)
        SyntaxTree::Go::BinaryExpr.new(x: x, op_pos: nil, op: op.to_sym, y: y)
      end

      def UnaryExpr(op, x)
        SyntaxTree::Go::UnaryExpr.new(op_pos: nil, op: op.to_sym, x: x)
      end

      def ParenExpr(x)
        SyntaxTree::Go::ParenExpr.new(lparen: nil, x: x, rparen: nil)
      end

      def KeyValueExpr(key, value)
        SyntaxTree::Go::KeyValueExpr.new(key: key, colon: nil, value: value)
      end

      def CompositeLit(type = nil, elts = [])
        SyntaxTree::Go::CompositeLit.new(
          type: type,
          lbrace: nil,
          elts: Array(elts),
          rbrace: nil,
          incomplete: false
        )
      end

      def ForStmt(cond = nil, body:, init: nil, post: nil)
        SyntaxTree::Go::ForStmt.new(
          for_: nil,
          init: init,
          cond: cond,
          post: post,
          body: body
        )
      end

      def RangeStmt(x, body:, key: nil, value: nil, tok: ":=")
        SyntaxTree::Go::RangeStmt.new(
          for_: nil,
          key: key,
          value: value,
          tok_pos: nil,
          tok: tok,
          range: nil,
          x: x,
          body: body
        )
      end

      def IfStmt(cond, body:, else_: nil, init: nil)
        SyntaxTree::Go::IfStmt.new(
          if_: nil,
          init: init,
          cond: cond,
          body: body,
          else_: else_
        )
      end

      def DeferStmt(call)
        SyntaxTree::Go::DeferStmt.new(defer: nil, call: call)
      end

      def GoStmt(call)
        SyntaxTree::Go::GoStmt.new(go: nil, call: call)
      end

      def BranchStmt(tok, label: nil)
        SyntaxTree::Go::BranchStmt.new(tok_pos: nil, tok: tok, label: label)
      end

      def PackageFile(name, nodes)
        imports = []
        declarations = []
        grouped_constants = []
        flush_constants =
          lambda do
            unless grouped_constants.empty?
              declarations << GenDecl(:const, grouped_constants)
              grouped_constants = []
            end
          end

        Array(nodes).each do |node|
          case node
          when SyntaxTree::Go::GenDecl
            case node.tok
            when :import
              imports.concat(node.specs)
            when :const
              node.specs.each do |spec|
                if spec.names.first.name.match?(/[A-Z]/)
                  grouped_constants << spec
                else
                  flush_constants.call
                  declarations << GenDecl(:const, [spec])
                end
              end
            else
              flush_constants.call
              declarations << node
            end
          else
            flush_constants.call
            declarations << node
          end
        end
        flush_constants.call
        rank = { const: 0, var: 1, type: 2, func: 3, other: 4 }
        declarations =
          declarations
            .each_with_index
            .sort_by do |declaration, index|
              category =
                if declaration.is_a?(SyntaxTree::Go::GenDecl)
                  declaration.tok
                elsif declaration.is_a?(SyntaxTree::Go::FuncDecl)
                  :func
                else
                  :other
                end
              [rank.fetch(category, 4), index]
            end
            .map(&:first)
        declarations.unshift(GenDecl(:import, imports)) unless imports.empty?

        File(name, declarations, imports: imports)
      end

      def File(name, decls = [], imports: [])
        SyntaxTree::Go::File.new(
          doc: nil,
          package: nil,
          name: name.is_a?(String) || name.is_a?(Symbol) ? Ident(name) : name,
          decls: Array(decls),
          file_start: nil,
          file_end: nil,
          scope: nil,
          imports: Array(imports),
          unresolved: [],
          comments: [],
          go_version: nil
        )
      end
    end
  end
end
