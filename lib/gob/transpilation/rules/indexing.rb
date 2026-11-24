# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Indexing
        module_function

        def register(matcher)
          matcher.rule(:pointer_index) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::ARef)

            node => SyntaxTree::ARef[
              collection: SyntaxTree::VarRef[
                value: SyntaxTree::IVar[value: name]
              ],
              index: SyntaxTree::Args[parts: [index]]
            ]

            UnaryExpr(
              :&,
              IndexExpr(Ident(name.delete_prefix("@")), visit(index))
            )
          end

          matcher.rule(:full_slice) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::ARef)

            node => SyntaxTree::ARef[collection: collection, index: nil]

            SliceExpr(visit(collection))
          end

          matcher.rule(:prefix_slice) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::ARef)

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
            next Matcher::MISS unless node.is_a?(SyntaxTree::ARef)

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
            next Matcher::MISS unless node.is_a?(SyntaxTree::ARef)

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
