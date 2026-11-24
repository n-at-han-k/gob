# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Concurrency
        module_function

        def register(matcher)
          matcher.rule(:defer) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "defer"],
              arguments: SyntaxTree::Args[parts: [call]]
            ]

            DeferStmt(visit(call))
          end

          matcher.rule(:go) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "go"],
              arguments: SyntaxTree::Args[parts: [call]]
            ]

            GoStmt(visit(call))
          end
        end
      end
    end
  end
end
