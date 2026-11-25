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
        def FunctionSignature(params, comments)
          params =
            case params
            in SyntaxTree::Params => node
              node
            in SyntaxTree::Paren[contents: SyntaxTree::Params => node]
              node
            end

          params => { requireds: requireds }

          signature_comment =
            case comments
            in [*, { value: /^\s*#\s*\(/ => comment }, *]
              comment
            else
              nil
            end

          signature =
            signature_comment&.match(
              /^\s*#\s*\((?<params>[^)]*)\)\s*->\s*(?<returns>.+)$/
            )

          parameter_types, return_text =
            case signature
            in { params: parameter_text, returns: returns_text }
              [
                parameter_text.split(",").map(&:strip).reject(&:empty?),
                returns_text.strip
              ]
            else
              [[], nil]
            end

          return_types =
            case return_text&.match(/^\((?<list>.*)\)$/)
            in { list: list }
              list.split(",").map(&:strip).reject(&:empty?)
            in nil
              return_text ? [return_text] : []
            else
              []
            end

          fields =
            requireds.each_with_index.map do |required, index|
              required => { value: parameter_name }

              type_text = parameter_types[index] || "any"
              type =
                case type_text.match(/^\*(?<element>.+)$/)
                in { element: element }
                  SyntaxTree::Go::StarExpr.new(
                    x: SyntaxTree::Go::Ident.new(name: element.strip)
                  )
                else
                  SyntaxTree::Go::Ident.new(name: type_text)
                end

              SyntaxTree::Go::Field.new(
                names: [SyntaxTree::Go::Ident.new(name: parameter_name)],
                type: type
              )
            end

          results =
            return_types.map do |type_text|
              type =
                case type_text.match(/^\*(?<element>.+)$/)
                in { element: element }
                  SyntaxTree::Go::StarExpr.new(
                    x: SyntaxTree::Go::Ident.new(name: element.strip)
                  )
                else
                  SyntaxTree::Go::Ident.new(name: type_text)
                end

              SyntaxTree::Go::Field.new(names: [], type: type)
            end

          results_field_list =
            case results
            in []
              nil
            else
              SyntaxTree::Go::FieldList.new(list: results)
            end

          SyntaxTree::Go::FuncType.new(
            params: SyntaxTree::Go::FieldList.new(list: fields),
            results: results_field_list
          )
        end

        def Function(name:, signature:, body:)
          name => { value: go_name }

          SyntaxTree::Go::FuncDecl.new(
            name: SyntaxTree::Go::Ident.new(name: go_name),
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
              params: { comments: } => params,
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body).then do |children|
                Function(
                  name: name,
                  signature: FunctionSignature(params, comments),
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
