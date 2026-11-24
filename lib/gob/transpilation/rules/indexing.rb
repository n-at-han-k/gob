# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Indexing
        module_function

        def register(matcher)
          matcher.rule(:full_slice) do |node|
            node => SyntaxTree::ARef[collection: collection, index: nil]

            SliceExpr(visit(collection))
          end

          matcher.rule(:prefix_slice) do |node|
            node => SyntaxTree::ARef[
              collection: collection,
              index: SyntaxTree::Args[
                parts: [
                  SyntaxTree::RangeNode[
                    left: nil,
                    operator: SyntaxTree::Op[value: "..."],
                    right: high
                  ]
                ]
              ]
            ]

            SliceExpr(visit(collection), high: visit(high))
          end

          matcher.rule(:bounded_slice) do |node|
            node => SyntaxTree::ARef[
              collection: collection,
              index: SyntaxTree::Args[
                parts: [
                  SyntaxTree::RangeNode[
                    left: low, operator: operator, right: high
                  ]
                ]
              ]
            ]

            next Matcher::MISS unless %w[.. ...].include?(operator.value)

            SliceExpr(visit(collection), low: visit(low), high: visit(high))
          end

          matcher.rule(:index) do |node|
            node => SyntaxTree::ARef[
              collection: collection, index: SyntaxTree::Args[parts: [index]]
            ]

            IndexExpr(visit(collection), visit(index))
          end
        end
      end
    end
  end
end
