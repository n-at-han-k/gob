#!/usr/bin/env ruby
#
# runner.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#

require "ostruct"

module Gob
  module Transpilation
    class Runner
      def call(tree)
        state = OpenStruct.new

        Context.new(tree.root).match do
          before do |ctx|
          end

          iterate do |ctx, node|
            case node
            in SyntaxTree::ModuleDeclaration[
              constant: SyntaxTree::ConstRef[ constant: SyntaxTree::Const[value: value] ],
              bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[body: body] ]
            ]
              ctx.descend(body).then do |children|
                options = {
                  children: children
                }
                Module(**options)
              end

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
      end
    end
  end
end
