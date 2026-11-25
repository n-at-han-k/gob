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
      module Nodes
        File = Struct.new(:children)
        Module = Struct.new(:children)
        Function = Struct.new(:children)
        Block = Struct.new(:children)
        Logic = Struct.new(:node)
        Comment = Struct.new(:node)
        Statement = Struct.new(:node)
      end

      def call(node)
        context = Context.new(node.statements.body)

        context.match do
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
              name: SyntaxTree::Const[value: _name],
              params: SyntaxTree::Paren[
                contents: SyntaxTree::Params[requireds: _parameters],
                comments: [SyntaxTree::Comment[value: /^#\s*\(/ => signature]]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body).then do |children|
                options = {
                  children: children
                }
                Function(**options)
              end

            in SyntaxTree::Begin[
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body).then do |children|
                options = {
                  children: children
                }
                Block(**options)
              end

            in SyntaxTree::IfNode[] |
              SyntaxTree::UnlessNode[] |
              SyntaxTree::WhileNode[] |
              SyntaxTree::UntilNode[] |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[
                message:  SyntaxTree::Ident[value: "loop"]
              ]] |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[
                message:  SyntaxTree::Ident[value: "each"]
              ]] => loop_node
              
              Logic(loop_node)

            in SyntaxTree::Comment => comment_node
              Comment(comment_node)

            else
              Statement(node)

            end
          end

          after do |ctx|
          end
        end

        context.tree
      end
    end

    class Context
      private

      def File(children:)
        Runner::Nodes::File.new(children)
      end

      def Module(children:)
        Runner::Nodes::Module.new(children)
      end

      def Function(children:)
        Runner::Nodes::Function.new(children)
      end

      def Block(children:)
        Runner::Nodes::Block.new(children)
      end

      def Logic(node)
        Runner::Nodes::Logic.new(node)
      end

      def Comment(node)
        Runner::Nodes::Comment.new(node)
      end

      def Statement(node)
        Runner::Nodes::Statement.new(node)
      end
    end
  end
end
