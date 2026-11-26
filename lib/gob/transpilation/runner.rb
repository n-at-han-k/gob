#!/usr/bin/env ruby
#
# runner.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#

module Gob
  module Transpilation
    class Runner
      module DefinitionNodes
        def parse_signature_comment(text)
          case text.split(/\s*->\s*/, 2)
          in [/\A#\s*\z/, ret] unless ret.empty?
            { params: [], returns: ret.delete_prefix("(").delete_suffix(")").split(/\s*,\s*/) }
          in [/\A#\s*\(([^)]*)\)\z/, ret] unless ret.empty?
            { params: $1.split(/\s*,\s*/), returns: ret.delete_prefix("(").delete_suffix(")").split(/\s*,\s*/) }
          in [/\A#\s*(.+)\z/, ret] unless ret.empty?
            { params: $1.split(/\s*,\s*/), returns: ret.delete_prefix("(").delete_suffix(")").split(/\s*,\s*/) }
          in [/\A#\s*\(([^)]*)\)\s*\z/]
            { params: $1.split(/\s*,\s*/), returns: [] }
          else
            { params: [], returns: [] }
          end
        end

        def Function(name:, params:, body:)
          case params
          in { contents: SyntaxTree::Params[requireds: args], comments: [SyntaxTree::Comment[value: types], *] }
            input, output = parse_signature_comment(types).values_at(:params, :returns)
            params = args.map { |arg|
              SyntaxTree::Go::Field.new(
                names: [ SyntaxTree::Go::Ident.new(name: arg.value) ],
                type: SyntaxTree::Go::Ident.new(name: input.shift)
              )
            }
            results = output.map { |result|
              SyntaxTree::Go::Field.new(
                names: [ SyntaxTree::Go::Ident.new(name: result) ],
              )
            }

          in { contents: SyntaxTree::Params[requireds: args] }
            params = args.map { |arg|
              SyntaxTree::Go::Field.new(
                names: [ SyntaxTree::Go::Ident.new(name: arg.value) ],
                type: SyntaxTree::Go::Ident.new(name: input.shift)
              )
            }
            results = []

          in { comments: [SyntaxTree::Comment[value: types], *] }
            _, output = parse_signature_comment(types).values_at(:params, :returns)
            params = []
            results = output.map { |result|
              SyntaxTree::Go::Field.new(
                names: [ SyntaxTree::Go::Ident.new(name: result) ],
              )
            }

          else
            params = []
            results = []

          end

          SyntaxTree::Go::FuncDecl.new(
            name: SyntaxTree::Go::Ident.new(name: name),
            type: SyntaxTree::Go::FuncType.new(
              type_params: nil,
              params: SyntaxTree::Go::FieldList.new(list: params),
              results: SyntaxTree::Go::FieldList.new(list: results),
            ),
            body: SyntaxTree::Go::BlockStmt.new(list: body)
          )
        end
      end

      module BlockNodes
        def Block(body:)
          SyntaxTree::Go::BlockStmt.new(list: body)
        end
      end

      module LogicNodes
        # if err != nil
        # if err
        # ---
        def Truthy(node)
          case node
          in SyntaxTree::Go::Ident[name: "err"]
            Binary(node, :!=, Ident(:nil))

          else
            node
          end
        end

        # unless err != nil
        # if err == nil
        # ---
        def Not(node)
          case node
          in SyntaxTree::Go::BinaryExpr[x: x, op: :!=, y: y]
            Binary(x, :==, y)

          in SyntaxTree::Go::BinaryExpr[x: x, op: :==, y: y]
            Binary(x, :!=, y)

          else
            SyntaxTree::Go::UnaryExpr.new(op: :!, x: node)
          end
        end

        # if err = f()
        # if err := f(); err != nil
        # ---
        def Guard(node)
          case node
          in SyntaxTree::Paren[contents: SyntaxTree::Statements[body: [statement]]]
            Guard(statement)

          in SyntaxTree::Assign | SyntaxTree::MAssign
            Statements(node).then { |init| [init, Truthy(init.lhs.last)] }

          else
            [nil, Truthy(LeftHand(node))]
          end
        end

        def Body(ctx, statements)
          ctx.descend(statements.body).then { |children| Block(body: children.tree) }
        end

        # if cond ... end
        # if cond { ... }
        # ---
        def If(ctx, predicate, statements, consequent)
          init, cond = Guard(predicate)

          SyntaxTree::Go::IfStmt.new(
            init:  init,
            cond:  cond,
            body:  Body(ctx, statements),
            else_: Logic(ctx, consequent)
          )
        end

        # unless cond ... end
        # if !cond { ... }
        # ---
        def Unless(ctx, predicate, statements, consequent)
          init, cond = Guard(predicate)

          SyntaxTree::Go::IfStmt.new(
            init:  init,
            cond:  Not(cond),
            body:  Body(ctx, statements),
            else_: Logic(ctx, consequent)
          )
        end

        # while cond ... end
        # for cond { ... }
        # ---
        def While(ctx, predicate, statements)
          init, cond = Guard(predicate)

          SyntaxTree::Go::ForStmt.new(
            init: init,
            cond: cond,
            post: nil,
            body: Body(ctx, statements)
          )
        end

        # until cond ... end
        # for !cond { ... }
        # ---
        def Until(ctx, predicate, statements)
          init, cond = Guard(predicate)

          SyntaxTree::Go::ForStmt.new(
            init: init,
            cond: Not(cond),
            post: nil,
            body: Body(ctx, statements)
          )
        end

        # loop do ... end
        # for { ... }
        # ---
        def Loop(ctx, statements)
          SyntaxTree::Go::ForStmt.new(
            init: nil,
            cond: nil,
            post: nil,
            body: Body(ctx, statements)
          )
        end

        # collection.each do |key, value| ... end
        # for key, value := range collection { ... }
        # ---
        def Each(ctx, collection, requireds, statements)
          key, value = requireds.map { |required| Ident(required.value) }

          SyntaxTree::Go::RangeStmt.new(
            key:   key,
            value: value,
            tok:   ":=",
            x:     LeftHand(collection),
            body:  Body(ctx, statements)
          )
        end

        def Logic(ctx, node)
          case node
          in SyntaxTree::IfNode[predicate: predicate, statements: statements, consequent: consequent]
            If(ctx, predicate, statements, consequent)

          in SyntaxTree::Elsif[predicate: predicate, statements: statements, consequent: consequent]
            If(ctx, predicate, statements, consequent)

          in SyntaxTree::UnlessNode[predicate: predicate, statements: statements, consequent: consequent]
            Unless(ctx, predicate, statements, consequent)

          in SyntaxTree::Else[statements: statements]
            Body(ctx, statements)

          in SyntaxTree::WhileNode[predicate: predicate, statements: statements]
            While(ctx, predicate, statements)

          in SyntaxTree::UntilNode[predicate: predicate, statements: statements]
            Until(ctx, predicate, statements)

          in SyntaxTree::MethodAddBlock[
            call: SyntaxTree::CallNode[
              message: SyntaxTree::Ident[value: "loop"]
            ],
            block: SyntaxTree::BlockNode[
              bodystmt: SyntaxTree::BodyStmt[statements: statements]
            ]
          ]
            Loop(ctx, statements)

          in SyntaxTree::MethodAddBlock[
            call: SyntaxTree::CallNode[
              receiver: collection,
              message: SyntaxTree::Ident[value: "each"]
            ],
            block: SyntaxTree::BlockNode[
              block_var: SyntaxTree::BlockVar[
                params: SyntaxTree::Params[requireds: requireds]
              ],
              bodystmt: SyntaxTree::BodyStmt[statements: statements]
            ]
          ]
            Each(ctx, collection, requireds, statements)

          else
            nil
          end
        end
      end

      module VariableNodes
        def Variable(node)
          case node
          in SyntaxTree::VarField[value: value]
            Variable(value)

          in SyntaxTree::VarRef[value: value]
            Variable(value)

          in SyntaxTree::VCall[value: value]
            Variable(value)

          in SyntaxTree::IVar[value: name]
            SyntaxTree::Go::UnaryExpr.new(
              op: :&,
              x: SyntaxTree::Go::Ident.new(name: name.delete_prefix("@"))
            )

          in SyntaxTree::CVar[value: name]
            SyntaxTree::Go::StarExpr.new(
              x: SyntaxTree::Go::Ident.new(name: name.delete_prefix("@@"))
            )

          # STATUS_ACTIVE
          # statusActive
          # ---
          in SyntaxTree::Const[value: name] if name == name.upcase
            Constant(name)

          in { value: name }
            SyntaxTree::Go::Ident.new(name: name)

          else
            nil
          end
        end

        # STATUS_ACTIVE
        # statusActive
        # ---
        def Constant(name)
          head, *tail = name.downcase.split("_")

          Ident(head + tail.map(&:capitalize).join)
        end

        def Ident(name)             = SyntaxTree::Go::Ident.new(name: name.to_s)
        def BasicLit(kind, value)   = SyntaxTree::Go::BasicLit.new(kind: kind.to_sym, value: value.to_s)
        def CharLiteral(value)      = BasicLit(:CHAR, "'#{value}'")
        def StringLiteral(value)    = BasicLit(:STRING, "\"#{value}\"")
        def RawStringLiteral(value) = BasicLit(:STRING, "`#{value}`")
        def IntLiteral(value)       = BasicLit(:INT, value)
        def FloatLiteral(value)     = BasicLit(:FLOAT, value)

        def Binary(left, operator, right) = SyntaxTree::Go::BinaryExpr.new(x: left, op: operator, y: right)

        def Call(node)
          case node

          # article.new(Title: "Learning Go")
          # article{Title: "Learning Go"}
          # ---
          in SyntaxTree::CallNode[
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Ident[value: "new"]
          ]
            Statements(node)

          in SyntaxTree::CallNode[
            receiver: receiver,
            operator: SyntaxTree::Period[value: "."],
            message: { value: message },
            arguments: SyntaxTree::ArgParen[arguments: arguments]
          ]
            SyntaxTree::Go::CallExpr.new(
              fun: SyntaxTree::Go::SelectorExpr.new(
                x: LeftHand(receiver),
                sel: Ident(message)
              ),
              args: Array(arguments&.parts).map { |argument| Statements(argument) }
            )

          in SyntaxTree::CallNode[
            receiver: nil,
            operator: nil,
            message: SyntaxTree::Ident[value: message],
            arguments: SyntaxTree::ArgParen[arguments: arguments]
          ]
            SyntaxTree::Go::CallExpr.new(
              fun: Ident(message),
              args: Array(arguments&.parts).map { |argument| Statements(argument) }
            )

          in SyntaxTree::CallNode[
            receiver: receiver,
            operator: SyntaxTree::Period[value: "."],
            message: { value: message },
            arguments: nil
          ]
            case receiver
            # @priv.PublicKey
            # &priv.PublicKey
            # ---
            in SyntaxTree::VarRef[value: SyntaxTree::IVar[value: name]]
              SyntaxTree::Go::UnaryExpr.new(
                op: :&,
                x: SyntaxTree::Go::SelectorExpr.new(
                  x:   Ident(name.delete_prefix("@")),
                  sel: Ident(message)
                )
              )

            # @@ast.Ident
            # *ast.Ident
            # ---
            in SyntaxTree::VarRef[value: SyntaxTree::CVar[value: name]]
              SyntaxTree::Go::StarExpr.new(
                x: SyntaxTree::Go::SelectorExpr.new(
                  x:   Ident(name.delete_prefix("@@")),
                  sel: Ident(message)
                )
              )

            else
              SyntaxTree::Go::SelectorExpr.new(x: LeftHand(receiver), sel: Ident(message))
            end

          else
            nil
          end
        end

      end

      module StatementNodes
        def Package(name:, declarations:)
          SyntaxTree::Go::File.new(
            name: SyntaxTree::Go::Ident.new(name: name.to_s),
            decls: declarations
          )
        end

        def LeftHand(node)
          case node
          in SyntaxTree::CallNode
            Call(node)

          in SyntaxTree::MLHS[parts: parts]
            parts.map { |part| LeftHand(part) }

          in SyntaxTree::MRHS[parts: parts]
            parts.map { |part| LeftHand(part) }

          in SyntaxTree::Int[value: text]
            IntLiteral(text)

          in SyntaxTree::FloatLiteral[value: text]
            FloatLiteral(text)

          in SyntaxTree::Binary[left: left, operator: operator, right: right]
            Binary(LeftHand(left), operator, LeftHand(right))



          in SyntaxTree::VarField[value: value]
            LeftHand(value)

          in SyntaxTree::VCall[value: value]
            LeftHand(value)

          in SyntaxTree::Field[parent: parent, operator: SyntaxTree::Period[value: "."], name: { value: name }]
            SyntaxTree::Go::SelectorExpr.new(x: LeftHand(parent), sel: Ident(name))

          in SyntaxTree::StringLiteral[parts: [SyntaxTree::TStringContent[value: text]]]
            StringLiteral(text)

          in SyntaxTree::StringLiteral[parts: []]
            StringLiteral("")

          in SyntaxTree::XStringLiteral[parts: [SyntaxTree::TStringContent[value: text]]]
            RawStringLiteral(text)

          else
            Variable(node)
          end
        end

        def RightHand(node) = Statements(node)

        # city = "Wellington"
        # city := "Wellington"
        # ---
        # x, y = 10, 20.5
        # x, y = 10, 20.5
        # ---
        def Assignment(ctx, target, value)
          lhs = Array(LeftHand(target))
          names = lhs.grep(SyntaxTree::Go::Ident).map(&:name) - ["_"]

          SyntaxTree::Go::AssignStmt.new(
            lhs:     lhs,
            tok_pos: nil,
            tok:     ctx.declare(names).any? ? ":=" : "=",
            rhs:     Array(RightHand(value))
          )
        end

        # var :name, string, "Nathan"
        # var name string = "Nathan"
        # ---
        # const :greeting, "hi"
        # const greeting = "hi"
        # ---
        def Declaration(tok, variable, type, value)
          SyntaxTree::Go::DeclStmt.new(
            decl: SyntaxTree::Go::GenDecl.new(
              tok: tok,
              specs: [
                SyntaxTree::Go::ValueSpec.new(
                  names:  [Ident(variable)],
                  type:   type && Statements(type),
                  values: value ? [Statements(value)] : []
                )
              ]
            )
          )
        end

        def Command(name, args)
          case [name, args]
          in ["require", [SyntaxTree::StringLiteral[parts: [SyntaxTree::TStringContent[value: path]]]]]
            ImportSpec(path)

          # var demos = Hash[string, Proc].new(...)
          # var demos = map[string]func(){...}
          # ---
          in ["var" | "const" => tok, [SyntaxTree::Assign[target: target, value: value]]]
            SyntaxTree::Go::GenDecl.new(
              tok: tok.to_sym,
              specs: [ SyntaxTree::Go::ValueSpec.new( names: [LeftHand(target)], values: [RightHand(value)] ) ]
            )

          # var mixed Array[byte, 16]
          # var mixed [16]byte
          # ---
          in ["var", [SyntaxTree::Command[
            message: SyntaxTree::Ident[value: variable],
            arguments: SyntaxTree::Args[ parts: [ type ] ]
          ]]]
            Declaration(:var, variable, type, nil)

          # var :a, int
          # var a int
          # ---
          in ["var", [SyntaxTree::SymbolLiteral[value: SyntaxTree::Ident[value: variable]], type]]
            Declaration(:var, variable, type, nil)

          # var :name, string, "Nathan"
          # var name string = "Nathan"
          # ---
          in ["var", [SyntaxTree::SymbolLiteral[value: SyntaxTree::Ident[value: variable]], type, value]]
            Declaration(:var, variable, type, value)

          # const :greeting, "hi"
          # const greeting = "hi"
          # ---
          in ["const", [SyntaxTree::SymbolLiteral[value: SyntaxTree::Ident[value: variable]], value]]
            Declaration(:const, variable, nil, value)

          else
            nil
          end
        end

        def Statements(node)
          case node
          in SyntaxTree::Assign[
            target: SyntaxTree::VarField[value: SyntaxTree::Ident[value: "err"]],
            value: SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: "getSomeValue"],
              arguments: SyntaxTree::ArgParen[arguments: nil]
            ]
          ]
            nil


          # Hash[string, bool]
          # map[string]bool
          # ---
          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[value: SyntaxTree::Const[value: "Hash"]],
            index: SyntaxTree::Args[ parts: [ key, value ] ]
          ]
            SyntaxTree::Go::MapType.new(
              key:   Statements(key),
              value: Statements(value)
            )

          # Array[string]
          # []string
          # ---
          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Array" ] ],
            index: SyntaxTree::Args[ parts: [ type ] ]
          ]
            SyntaxTree::Go::ArrayType.new( len: nil, elt: Statements(type) )

          # Array[string, 5]
          # [5]string
          # ---
          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Array" ] ],
            index: SyntaxTree::Args[ parts: [ type, size ] ]
          ]
            SyntaxTree::Go::ArrayType.new( len: Statements(size), elt: Statements(type) )

          # Proc
          # func()
          # ---
          in SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Proc" ] ]
            SyntaxTree::Go::FuncType.new(
              params:  SyntaxTree::Go::FieldList.new(list: []),
              results: nil
            )

          # Array[byte].new("hello")
          # []byte("hello")
          # ---
          in SyntaxTree::CallNode[
            receiver: SyntaxTree::ARef[
              collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[value: "Array"] ],
              index: SyntaxTree::Args[
                parts: [ SyntaxTree::VCall[value: SyntaxTree::Ident[value: "byte" | "rune"]] ]
              ]
            ] => receiver,
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Ident[value: "new"],
            arguments: SyntaxTree::ArgParen[
              arguments: SyntaxTree::Args[ parts: [ SyntaxTree::StringLiteral => text ] ]
            ]
          ]
            SyntaxTree::Go::CallExpr.new(
              fun:  Statements(receiver),
              args: [ Statements(text) ]
            )

          # @url.URL.new(Scheme: "https")
          # &url.URL{Scheme: "https"}
          # ---
          in SyntaxTree::CallNode[
            receiver: SyntaxTree::CallNode[
              receiver: SyntaxTree::VarRef[ value: SyntaxTree::IVar[value: name] ],
              operator: SyntaxTree::Period[value: "."],
              message: { value: selector }
            ],
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Ident[value: "new"],
            arguments: arguments
          ]
            SyntaxTree::Go::UnaryExpr.new(
              op: :&,
              x: SyntaxTree::Go::CompositeLit.new(
                type: SyntaxTree::Go::SelectorExpr.new(
                  x:   Ident(name.delete_prefix("@")),
                  sel: Ident(selector)
                ),
                elts: Array(arguments&.arguments&.parts).flat_map { |item| Statements(item) }
              )
            )

          # Array[string].new("go", "stdlib")
          # Hash[string, int].new("answer" => 42)
          # article.new(Title: "Learning Go")
          # []string{"go", "stdlib"}
          # map[string]int{"answer": 42}
          # article{Title: "Learning Go"}
          # ---
          in SyntaxTree::CallNode[
            receiver: receiver,
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Ident[value: "new"],
            arguments: arguments
          ]
            SyntaxTree::Go::CompositeLit.new(
              type: Statements(receiver),
              elts: Array(arguments&.arguments&.parts).flat_map { |item| Statements(item) }
            )

          # Title: "Learning Go"
          # Title: "Learning Go"
          # ---
          in SyntaxTree::BareAssocHash[ assocs: assocs ]
            assocs.map { |assoc| Statements(assoc) }

          in SyntaxTree::Assoc[
            key: SyntaxTree::Label[value: label],
            value: value
          ]
            SyntaxTree::Go::KeyValueExpr.new(
              key:   Ident(label.delete_suffix(":")),
              value: Statements(value)
            )

          # "q": ["go & rust"]
          # "q": {"go & rust"}
          # ---
          in SyntaxTree::Assoc[
            key: SyntaxTree::DynaSymbol[parts: [SyntaxTree::TStringContent[value: text]]],
            value: value
          ]
            SyntaxTree::Go::KeyValueExpr.new(
              key:   StringLiteral(text),
              value: Statements(value)
            )

          in SyntaxTree::Assoc[ key: key, value: value ]
            SyntaxTree::Go::KeyValueExpr.new(
              key:   Statements(key),
              value: Statements(value)
            )

          # ["go & rust"]
          # {"go & rust"}
          # ---
          in SyntaxTree::ArrayLiteral[ contents: SyntaxTree::Args[ parts: parts ] ]
            SyntaxTree::Go::CompositeLit.new(
              type: nil,
              elts: parts.map { |part| Statements(part) }
            )

          # demos[os.Args[1]]
          # demos[os.Args[1]]
          # ---
          in SyntaxTree::ARef[ collection: collection, index: SyntaxTree::Args[ parts: [ index ] ] ]
            SyntaxTree::Go::IndexExpr.new(
              x:     Statements(collection),
              index: Statements(index)
            )

          #in SyntaxTree::ARef[collection: collection, index: SyntaxTree::Args[parts: [index]]]
          #  SyntaxTree::Go::IndexExpr.new(
          #    x: LeftHand(collection),
          #    index: LeftHand(index)
          #  )

          #in SyntaxTree::ARefField[collection: collection, index: SyntaxTree::Args[parts: [index]]]
          #  SyntaxTree::Go::IndexExpr.new(
          #    x: LeftHand(collection),
          #    index: LeftHand(index)
          #  )

          #in SyntaxTree::Go::ReturnStmt
          #  SyntaxTree::Go::ReturnStmt.new(return_: nil, results: nil)

          #in SyntaxTree::Go::IncDecStmt
          #  SyntaxTree::Go::IncDecStmt.new(x: nil, tok_pos: nil, tok: nil)

          #in SyntaxTree::Go::ExprStmt
          #  SyntaxTree::Go::ExprStmt.new(x: nil)

          #in SyntaxTree::Go::IndexExpr
          #  SyntaxTree::Go::IndexStmt.new(x: nil)

          #in SyntaxTree::Go::SliceExpr
          #  SyntaxTree::Go::SliceStmt.new(x: nil)

          #in SyntaxTree::Go::SelectorExpr
          #  SyntaxTree::Go::SelectorExpr.new(x: nil)

          #in SyntaxTree::Go::ArrayType
          #  SyntaxTree::Go::ArrayType.new(x: nil)

          #in SyntaxTree::Go::MapType
          #  SyntaxTree::Go::MapType.new(x: nil)

          #in SyntaxTree::Go::StarExpr
          #  SyntaxTree::Go::StarExpr.new(x: nil)

          #in SyntaxTree::Go::UnaryExpr
          #  SyntaxTree::Go::UnaryExpr.new(x: nil)
 
          #in SyntaxTree::Go::KeyValueExpr
          #  SyntaxTree::Go::KeyValueExpr.new(x: nil)
 
          #in SyntaxTree::Go::CompositeLit
          #  SyntaxTree::Go::CompositeLit.new(x: nil)

          in SyntaxTree::Command[
            message: SyntaxTree::Ident[value: name],
            arguments: SyntaxTree::Args[parts: args]
          ]
            Command(name, args)

          in SyntaxTree::CallNode
            Call(node)

          in SyntaxTree::Assign[target: target, value: value]
            SyntaxTree::Go::AssignStmt.new(
              lhs:     Array(LeftHand(target)),
              tok_pos: nil,
              tok:     ":=",
              rhs:     Array(RightHand(value))
            )

          in SyntaxTree::MAssign[
            target: SyntaxTree::MLHS[
              parts: [
                SyntaxTree::VarField[value: SyntaxTree::Ident[value: "_"]],
                SyntaxTree::VarField[value: SyntaxTree::Ident[value: "err"]]
              ]
            ],
            value: SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: "getSomeValue"],
              arguments: SyntaxTree::ArgParen[arguments: nil]
            ]
          ]
            nil

          in SyntaxTree::MAssign[target: target, value: value]
            SyntaxTree::Go::AssignStmt.new(
              lhs:     Array(LeftHand(target)),
              tok_pos: nil,
              tok:     ":=",
              rhs:     Array(RightHand(value))
            )

          in SyntaxTree::MethodAddBlock[
            call: SyntaxTree::CallNode[
              receiver: SyntaxTree::Paren[
                contents: SyntaxTree::Statements[
                  body: [
                    SyntaxTree::RangeNode[
                      left: SyntaxTree::Int[value: "1"],
                      operator: SyntaxTree::Op[value: ".."],
                      right: SyntaxTree::Int[value: "5"]
                    ]
                  ]
                ]
              ],
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "each"]
            ],
            block: SyntaxTree::BlockNode[
              block_var: SyntaxTree::BlockVar[
                params: SyntaxTree::Params[
                  requireds: [SyntaxTree::Ident[value: "i"]]
                ]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[
                  body: [SyntaxTree::VarRef[value: SyntaxTree::Ident[value: "i"]]]
                ]
              ]
            ]
          ]
            nil

          # break
          # break
          # ---
          in SyntaxTree::Break
            SyntaxTree::Go::BranchStmt.new(tok: :break)

          # next
          # continue
          # ---
          in SyntaxTree::Next
            SyntaxTree::Go::BranchStmt.new(tok: :continue)

          # return "discarded", "kept"
          # return "discarded", "kept"
          # ---
          in SyntaxTree::ReturnNode[arguments: SyntaxTree::Args[ parts: parts ]]
            SyntaxTree::Go::ReturnStmt.new(results: parts.map { |part| Statements(part) })

          # return
          # return
          # ---
          in SyntaxTree::ReturnNode
            SyntaxTree::Go::ReturnStmt.new(results: [])

          # :int32
          # int32
          # ---
          in SyntaxTree::SymbolLiteral[value: SyntaxTree::Ident[value: name]]
            Ident(name)

          in SyntaxTree::VoidStmt
            nil
          else
            LeftHand(node)
          end
        end

        def ImportSpec(path, name: nil)
          SyntaxTree::Go::ImportSpec.new(
            doc: nil,
            name: name,
            path: StringLiteral(path),
            comment: nil,
            end_pos: nil
          )
        end

      end

      def call(node)
        root_context = Context.new(node.statements.body)

        root_context.match do
          before do |ctx|
          end

          iterate do |ctx, node|
            case node
            in SyntaxTree::ModuleDeclaration[
              constant: SyntaxTree::ConstRef[
                constant: SyntaxTree::Const[value: "Main"]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              Hoist.new(body)

            in SyntaxTree::DefNode[
              name: { value: name },
              params: params,
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body).then do |children|
                Function(
                  name: name,
                  params: params,
                  body: children.tree
                )
              end

            in SyntaxTree::Begin[
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body, inherit: false).then do |children|
                Block(body: children.tree)
              end

            in SyntaxTree::IfNode | SyntaxTree::UnlessNode | SyntaxTree::WhileNode | SyntaxTree::UntilNode |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[ message: SyntaxTree::Ident[value: "loop"] ]] |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[ message: SyntaxTree::Ident[value: "each"] ]] => logic_node
              Logic(ctx, logic_node)

            in SyntaxTree::CallNode
              SyntaxTree::Go::ExprStmt.new(x: Statements(node))

            in SyntaxTree::Comment[value: value]
              SyntaxTree::Go::Comment.new(text: value.sub(/\A#/, "//"))

            # PI = 3.14159
            # const pi = 3.14159
            # ---
            in SyntaxTree::Assign[
              target: SyntaxTree::VarField[value: SyntaxTree::Const[value: name]],
              value: value
            ] if ctx.equal?(root_context)
              SyntaxTree::Go::GenDecl.new(
                tok: :const,
                specs: [ SyntaxTree::Go::ValueSpec.new( names: [Constant(name)], values: [RightHand(value)] ) ]
              )

            # packageLevel = "I live at package scope"
            # var packageLevel = "I live at package scope"
            # ---
            in SyntaxTree::Assign[target: target, value: value] if ctx.equal?(root_context)
              SyntaxTree::Go::GenDecl.new(
                tok: :var,
                specs: [ SyntaxTree::Go::ValueSpec.new( names: [LeftHand(target)], values: [RightHand(value)] ) ]
              )

            in SyntaxTree::Assign[target: target, value: value]
              Assignment(ctx, target, value)

            in SyntaxTree::MAssign[target: target, value: value]
              Assignment(ctx, target, value)

            else
              Statements(node)
            end
          end

          after do |ctx|
            if ctx.equal?(root_context)
              ctx.tree.unshift(SyntaxTree::Go::GenDecl.new(
                tok: :import,
                specs: ctx.tree.select { |node| node.is_a?(SyntaxTree::Go::ImportSpec) }
              ))
              ctx.tree.reject! { |node| node.is_a?(SyntaxTree::Go::ImportSpec) }
              file = Package(name: "main", declarations: ctx.tree.dup)
              ctx.tree.replace([file])
            end
          end
        end

        root_context.tree.first
      end
    end

    class Context
      include Runner::DefinitionNodes
      include Runner::StatementNodes

      include Runner::LogicNodes
      include Runner::BlockNodes
      include Runner::VariableNodes
    end
  end
end
