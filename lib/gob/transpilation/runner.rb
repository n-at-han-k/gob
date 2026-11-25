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
      module PackageNodes
        def Package(name:, declarations:)
          SyntaxTree::Go::File.new(
            name: SyntaxTree::Go::Ident.new(name: name.to_s),
            decls: declarations
          )
        end
      end

      module FunctionNodes
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
                names: [ SyntaxTree::Go::Ident.new(name: result.value) ],
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
                names: [ SyntaxTree::Go::Ident.new(name: result.value) ],
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
            message: SyntaxTree::Const[value: message],
            arguments: SyntaxTree::ArgParen[arguments: arguments]
          ]
            nil

          in SyntaxTree::CallNode[
            receiver: nil,
            operator: nil,
            message: SyntaxTree::Ident[value: message],
            arguments: SyntaxTree::ArgParen[arguments: arguments]
          ]
            nil

          in SyntaxTree::CallNode[
            receiver: receiver,
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Const[value: message],
            arguments: nil
          ]
            nil
          else
            nil
          end
        end

      end

      module StatementNodes
        def LeftHand(node)
          case node
          in SyntaxTree::CallNode
            Call(node)
          in SyntaxTree::MLHS[parts: parts]
            parts.map { |part| LeftHand(part) }
          in SyntaxTree::Int[value: text]
            IntLiteral(text)
          in SyntaxTree::FloatLiteral[value: text]
            FloatLiteral(text)
          in SyntaxTree::Binary[left: left, operator: operator, right: right]
            Binary(left, operator, right)
          in SyntaxTree::ARef[ collection: collection, index: SyntaxTree::Args[parts: [index]]]
            nil
          in SyntaxTree::VarField[value: value]
            nil
          in SyntaxTree::StringLiteral[parts: [SyntaxTree::TStringContent[value: text]]]
            nil
          in SyntaxTree::StringLiteral[parts: []]
            nil
          in SyntaxTree::XStringLiteral[parts: [SyntaxTree::TStringContent[value: text]]]
            nil
          else
            nil
          end
        end

        def RightHand(node)
          case node
          in SyntaxTree::CallNode
            Call(node)
          in SyntaxTree::MRHS[parts: parts]
            parts.map { |part| RightHand(part) }
          in SyntaxTree::Int[value: text]
            IntLiteral(text)
          in SyntaxTree::FloatLiteral[value: text]
            FloatLiteral(text)
          in SyntaxTree::Binary[left: left, operator: operator, right: right]
            Binary(left, operator, right)
          in SyntaxTree::ARef[ collection: collection, index: SyntaxTree::Args[parts: [index]]]
            nil
          in SyntaxTree::VarField[value: value]
            nil
          in SyntaxTree::StringLiteral[parts: [SyntaxTree::TStringContent[value: text]]]
            nil
          in SyntaxTree::StringLiteral[parts: []]
            nil
          in SyntaxTree::XStringLiteral[parts: [SyntaxTree::TStringContent[value: text]]]
            nil
          else
            nil
          end
        end

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

          in SyntaxTree::CallNode[ receiver: object, operator: operator, message: SyntaxTree::Ident[value: method] ]
            Call(object, operator, method)

          in SyntaxTree::Assign[target: target, value: value]
            SyntaxTree::Go::AssignStmt.new(
              lhs:     LeftHand(target),
              tok_pos: nil,
              tok:     ":=",
              rhs:     RightHand(value)
            )

          in SyntaxTree::MAssign[target: target, value: value]
            SyntaxTree::Go::AssignStmt.new(
              lhs:     LeftHand(target),
              tok_pos: nil,
              tok:     ":=",
              rhs:     RightHand(value)
            )

          in SyntaxTree::Assign[target: target, value: value]
            SyntaxTree::Go::AssignStmt.new(
              lhs: [Variable(target)],
              tok: ":=",
              rhs: Expression(value)
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
              SyntaxTree::Go::Comment.new(text: value)

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
      include Runner::PackageNodes
      include Runner::FunctionNodes
      include Runner::BlockNodes
      include Runner::LogicNodes
      include Runner::VariableNodes
      include Runner::StatementNodes
    end
  end
end
