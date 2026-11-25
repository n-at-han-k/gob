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
        def Function(name:, params:, body:)
          SyntaxTree::Go::FuncDecl.new(
            name: SyntaxTree::Go::Ident.new(name: "main"),
            type: SyntaxTree::Go::FuncType.new(
              type_params: nil,
              params: SyntaxTree::Go::FieldList.new(list: [
                SyntaxTree::Go::Field.new(
                  names: [ SyntaxTree::Go::Ident.new(name: "yehmam") ],
                  type: SyntaxTree::Go::Ident.new(name: "eyup")
                )
              ]),
              results: nil
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
          in SyntaxTree::VoidStmt
            nil
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

                #contents: SyntaxTree::Params[requireds: _parameters],
                #comments: [SyntaxTree::Comment[value: /^#\s*\(/ => signature]]
            in SyntaxTree::DefNode[
              target: nil,
              operator: nil,
              name: name,
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
