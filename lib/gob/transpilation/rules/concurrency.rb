# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Concurrency
        module_function

        def register(matcher)
          matcher.rule(:defer_block) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::MethodAddBlock)

            node => SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: nil,
                operator: nil,
                message: SyntaxTree::Ident[value: "defer"]
              ]
            ]

            Matcher::DROP
          end

          matcher.rule(:defer) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "defer"],
              arguments: SyntaxTree::Args[parts: [call]]
            ]

            call = visit(call)
            next Matcher::DROP unless call.is_a?(SyntaxTree::Go::CallExpr)

            DeferStmt(call)
          end

          matcher.rule(:go) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "go"],
              arguments: SyntaxTree::Args[parts: [call]]
            ]

            call = visit(call)
            next Matcher::DROP unless call.is_a?(SyntaxTree::Go::CallExpr)

            GoStmt(call)
          end
        end
      end
    end
  end
end
