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
        def Logic(node)
          nil
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

          in { value: name }
            SyntaxTree::Go::Ident.new(name: name)

          else
            nil
          end
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
              args: Array(arguments&.parts).map { |argument| LeftHand(argument) }
            )

          in SyntaxTree::CallNode[
            receiver: nil,
            operator: nil,
            message: SyntaxTree::Ident[value: message],
            arguments: SyntaxTree::ArgParen[arguments: arguments]
          ]
            SyntaxTree::Go::CallExpr.new(
              fun: Ident(message),
              args: Array(arguments&.parts).map { |argument| LeftHand(argument) }
            )

          in SyntaxTree::CallNode[
            receiver: receiver,
            operator: SyntaxTree::Period[value: "."],
            message: { value: message },
            arguments: nil
          ]
            x =
              case receiver
              in SyntaxTree::VarRef[value: SyntaxTree::IVar[value: name]]
                SyntaxTree::Go::StarExpr.new(x: Ident(name.delete_prefix("@")))
              else
                LeftHand(receiver)
              end

            SyntaxTree::Go::SelectorExpr.new(x: x, sel: Ident(message))

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

        def RightHand(node) = LeftHand(node)

        def Command(name, args)
          case [name, args]
          in ["require", [SyntaxTree::StringLiteral[parts: [SyntaxTree::TStringContent[value: path]]]]]
            ImportSpec(path)
          in ["var", _]
            nil
          in ["const", _]
            nil
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
            index: SyntaxTree::Args[
              parts: [
                SyntaxTree::VCall[value: SyntaxTree::Ident[value: key]],
                SyntaxTree::VCall[value: SyntaxTree::Ident[value: value]]
              ]
            ]
          ]
            SyntaxTree::Go::MapType.new( )

          # Array[string, 5]
          # [5]string
          # ---
          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Array" ] ],
            index: SyntaxTree::Args[ parts: [ type, *size ] ]
          ]
            (size || nil).then do |size|
              case type
              in SyntaxTree::VCall[ value: SyntaxTree::Ident[ value: name ] ]
                SyntaxTree::Go::ArrayType.new( len: size, elt: Ident(name) )
              end
            end

          # Array[string].new()
          # Hash[string, int].new()
          # [5]string{}
          # map[string]int{}
          # ---
          in SyntaxTree::CallNode[
            receiver: SyntaxTree::ARef[
              collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[value: "Array" | "Hash"] ],
              index: SyntaxTree::Args[ parts: args ]
            ] => receiver,
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Ident[value: "new"],
            arguments: SyntaxTree::ArgParen[
              arguments: SyntaxTree::Args[ parts: items ]
            ]
          ]
            Statements(receiver)

          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Array" ] ],
            index: SyntaxTree::Args[ parts: [ type, *size ] ]
          ]
            (size || nil).then do |size|
              case type
              in SyntaxTree::VCall[ value: SyntaxTree::Ident[ value: name ] ]
                SyntaxTree::Go::ArrayType.new( len: size, elt: Ident(name) )
              end
            end

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
            SyntaxTree::Go::ExprStmt.new(x: Call(node))

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

          in SyntaxTree::VoidStmt
            nil
          else
            nil
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
              ctx.descend(body).then do |children|
                Block(body: children.tree)
              end

            in SyntaxTree::IfNode[] |
              SyntaxTree::UnlessNode[] |
              SyntaxTree::WhileNode[] |
              SyntaxTree::UntilNode[] |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[
                message: SyntaxTree::Ident[value: "loop"]
              ]] |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[
                message: SyntaxTree::Ident[value: "each"]
              ]] => logic_node
              Logic(logic_node)

            in SyntaxTree::Comment[value: value]
              SyntaxTree::Go::Comment.new(text: value.sub(/\A#/, "//"))

            in SyntaxTree::Assign[target: target, value: value] if ctx.equal?(root_context)
              SyntaxTree::Go::GenDecl.new(
                tok: :var,
                specs: [
                  SyntaxTree::Go::ValueSpec.new(
                    names: [LeftHand(target)],
                    values: [RightHand(value)]
                  )
                ]
              )

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
