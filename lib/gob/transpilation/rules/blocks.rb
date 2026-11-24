# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Blocks
        module_function

        def register(matcher)
          matcher.rule(:begin_block) do |node|
            node => SyntaxTree::Begin[
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]

            BlockStmt(
              scoped do
                visit_all(body).map { |statement| stmtify(statement) }
              end
            )
          end
          matcher.rule(:bare_assoc_hash) { Matcher::MISS }
          matcher.rule(:hash_literal) { Matcher::MISS }
          matcher.rule(:array_literal) { Matcher::MISS }
          matcher.rule(:block_arguments) { Matcher::MISS }
        end
      end
    end
  end
end
