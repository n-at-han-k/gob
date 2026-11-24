# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Loops
        module_function

        def register(matcher)
          matcher.rule(:while_loop) { Matcher::MISS }
          matcher.rule(:until_loop) { Matcher::MISS }
          matcher.rule(:loop_block) { Matcher::MISS }
          matcher.rule(:each_block) { Matcher::MISS }
          matcher.rule(:times_block) { Matcher::MISS }
          matcher.rule(:break) { Matcher::MISS }
          matcher.rule(:next) { Matcher::MISS }
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

            ReturnStmt
          end
        end
      end
    end
  end
end
