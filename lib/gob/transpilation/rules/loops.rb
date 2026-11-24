# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Loops
        module_function

        def register(matcher)
          matcher.rule(:while_loop) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::WhileNode)

            node => SyntaxTree::WhileNode[
              predicate: predicate,
              statements: SyntaxTree::Statements[body: body]
            ]

            WhileLoop(predicate, body, context: self)
          end

          matcher.rule(:until_loop) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::UntilNode)

            node => SyntaxTree::UntilNode[
              predicate: predicate,
              statements: SyntaxTree::Statements[body: body]
            ]

            UntilLoop(predicate, body, context: self)
          end

          matcher.rule(:loop_block) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::MethodAddBlock)

            node => SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: nil,
                operator: nil,
                message: SyntaxTree::Ident[value: "loop"]
              ],
              block: SyntaxTree::BlockNode[bodystmt: bodystmt]
            ]

            LoopBlock(BodyStatements(bodystmt), context: self)
          end

          matcher.rule(:each_block) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::MethodAddBlock)

            node => SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: receiver,
                operator: SyntaxTree::Period[value: "."],
                message: SyntaxTree::Ident[value: "each"]
              ],
              block: SyntaxTree::BlockNode[
                block_var: block_var, bodystmt: bodystmt
              ]
            ]

            Each(
              receiver,
              ParameterNodes(BlockParameters(block_var)),
              BodyStatements(bodystmt),
              context: self
            )
          end

          matcher.rule(:times_block) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::MethodAddBlock)

            node => SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: count,
                operator: SyntaxTree::Period[value: "."],
                message: SyntaxTree::Ident[value: "times"]
              ],
              block: SyntaxTree::BlockNode[
                block_var: block_var, bodystmt: bodystmt
              ]
            ]

            Times(
              count,
              ParameterNodes(BlockParameters(block_var)),
              BodyStatements(bodystmt),
              context: self
            )
          end

          matcher.rule(:break) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Break)

            node => SyntaxTree::Break[arguments: SyntaxTree::Args[parts: []]]

            BranchStmt(:break)
          end

          matcher.rule(:next) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Next)

            node => SyntaxTree::Next[arguments: SyntaxTree::Args[parts: []]]

            BranchStmt(:continue)
          end

          matcher.rule(:return) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::ReturnNode)

            node => SyntaxTree::ReturnNode[
              arguments: SyntaxTree::Args[parts: parts]
            ]

            ReturnStmt(visit_all(parts))
          end

          matcher.rule(:bare_return) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::ReturnNode)

            node => SyntaxTree::ReturnNode[arguments: nil]

            ReturnStmt()
          end
        end
      end
    end
  end
end
