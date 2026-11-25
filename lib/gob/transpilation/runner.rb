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
        def FunctionSignature(fields, returns)
          case returns
          in []
            SyntaxTree::Go::FuncType.new(
              params: SyntaxTree::Go::FieldList.new(list: fields),
              results: nil
            )
          else
            SyntaxTree::Go::FuncType.new(
              params: SyntaxTree::Go::FieldList.new(list: fields),
              results: SyntaxTree::Go::FieldList.new(
                list: returns.map do |type|
                  SyntaxTree::Go::Field.new(
                    names: [],
                    type: SyntaxTree::Go::Ident.new(name: type)
                  )
                end
              )
            )
          end
        end

        def Signature(comments)
          comment =
            comments.map(&:value).find { |value| value.match?(/^\s*#\s*\(/) }

          groups =
            comment.to_s.scan(/\(([^)]*)\)/).flatten.map do |text|
              text.split(",").map(&:strip).reject(&:empty?)
            end

          groups.empty? ? [[], []] : groups
        end

        def Function(name:, signature:, body:)
          SyntaxTree::Go::FuncDecl.new(
            name: Variable(name),
            type: signature,
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

      module CommentNodes
        def Comment(value:)
          SyntaxTree::Go::Comment.new(text: value)
        end
      end

      module VariableNodes
        def Variable(node)
          case node
          in SyntaxTree::CVar[value: name]
            SyntaxTree::Go::StarExpr.new(
              x: SyntaxTree::Go::Ident.new(name: name.delete_prefix("@@"))
            )

          in { value: name }
            SyntaxTree::Go::Ident.new(name: name)
          end
        end
      end

      module StatementNodes
        def Statements(node)
          case node
          in {
            message: { value: "require" },
            arguments: { parts: [{ parts: [{ value: path }] }] }
          }
            SyntaxTree::Go::GenDecl.new(
              tok: :import,
              specs: [
                SyntaxTree::Go::ImportSpec.new(
                  path: SyntaxTree::Go::BasicLit.new(
                    kind: :STRING,
                    value: %("#{path}")
                  )
                )
              ]
            )

          in SyntaxTree::VoidStmt
            nil

          in SyntaxTree::Assign[
            target: { value: target },
            value: value
          ]
            rhs =
              case value
              in { parts: [{ value: text }] }
                SyntaxTree::Go::BasicLit.new(
                  kind: :STRING,
                  value: %("#{text}")
                )

              in { value: token }
                Variable(token)

              in {
                receiver: receiver,
                operator: { value: "." },
                message: { value: name },
                arguments: arguments
              }
                parts =
                  case arguments
                  in { arguments: { parts: values } }
                    values
                  in { parts: values }
                    values
                  else
                    []
                  end

                args =
                  parts.map do |part|
                    case part
                    in { parts: [{ value: text }] }
                      SyntaxTree::Go::BasicLit.new(
                        kind: :STRING,
                        value: %("#{text}")
                      )
                    in { value: token }
                      Variable(token)
                    else
                      SyntaxTree::Go::Ident.new(name: "nil")
                    end
                  end

                fun =
                  case receiver
                  in { value: { value: text } }
                    SyntaxTree::Go::Ident.new(name: text)
                  in { value: token }
                    Variable(token)
                  else
                    SyntaxTree::Go::Ident.new(name: "nil")
                  end

                SyntaxTree::Go::CallExpr.new(
                  fun: SyntaxTree::Go::SelectorExpr.new(
                    x: fun,
                    sel: SyntaxTree::Go::Ident.new(name: name)
                  ),
                  args: args
                )

              else
                SyntaxTree::Go::Ident.new(name: "nil")
              end

            SyntaxTree::Go::AssignStmt.new(
              lhs: [Variable(target)],
              tok: "=",
              rhs: [rhs]
            )

          in {
            receiver: receiver,
            operator: { value: "." },
            message: { value: name },
            arguments: arguments
          }
            fun =
              case receiver
              in { value: { value: value } }
                SyntaxTree::Go::Ident.new(name: value)
              in { value: value }
                Variable(value)
              else
                SyntaxTree::Go::Ident.new(name: "nil")
              end

            parts =
              case arguments
              in { arguments: { parts: values } }
                values
              in { parts: values }
                values
              else
                []
              end

            args =
              parts.map do |part|
                case part
                in { parts: [{ value: value }] }
                  SyntaxTree::Go::BasicLit.new(
                    kind: :STRING,
                    value: %("#{value}")
                  )
                in { value: { value: value } }
                  SyntaxTree::Go::Ident.new(name: value)
                in { value: value }
                  Variable(value)
                else
                  SyntaxTree::Go::Ident.new(name: "nil")
                end
              end

            SyntaxTree::Go::ExprStmt.new(
              x: SyntaxTree::Go::CallExpr.new(
                fun: SyntaxTree::Go::SelectorExpr.new(
                  x: fun,
                  sel: SyntaxTree::Go::Ident.new(name: name)
                ),
                args: args
              )
            )

          in { parts: [{ value: value }] }
            SyntaxTree::Go::ExprStmt.new(
              x: SyntaxTree::Go::BasicLit.new(
                kind: :STRING,
                value: %("#{value}")
              )
            )

          else
            nil
          end
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
              target: nil,
              operator: nil,
              name: name,
              params: SyntaxTree::Params[
                requireds: requireds,
                comments: comments
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body).then do |children|
                Signature(comments) => [types, returns]

                Function(
                  name: name,
                  signature: FunctionSignature(
                    requireds.each_with_index.map do |required, index|
                      SyntaxTree::Go::Field.new(
                        names: [Variable(required)],
                        type: SyntaxTree::Go::Ident.new(name: types[index] || "any")
                      )
                    end,
                    returns
                  ),
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
              Comment(value: value)

            else
              Statements(node)
            end
          end

          after do |ctx|
            if ctx.equal?(root_context)
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
      include Runner::CommentNodes
      include Runner::VariableNodes
      include Runner::StatementNodes
    end
  end
end
