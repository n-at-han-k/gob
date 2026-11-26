# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Folds literal shifts in array sizes, where `<<` would mean a channel send.
      class ArrayLength < Cop
        MSG = "Use the evaluated array length `%<length>d`, not `%<source>s`"

        private

          # Array[byte, 1 << 20]
          # Array[byte, 1_048_576]
          # ---
          def rule(node)
            case node
            in SyntaxTree::ARef[
              collection: SyntaxTree::VarRef[value: SyntaxTree::Const[value: "Array"]],
              index: SyntaxTree::Args[parts: [_, length]]
            ] if (evaluated = literal_shift(length))
              add_offense(range(length.location), message: format(MSG, length: evaluated, source: source(length.location))) do |corrector|
                corrector.replace(range(length.location), evaluated.to_s)
              end

            else
              nil
            end
          end

          def literal_shift(node)
            case node
            in SyntaxTree::Binary[
              left: SyntaxTree::Int[value: left],
              operator: :<<,
              right: SyntaxTree::Int[value: right]
            ]
              left.to_i << right.to_i
            else
              nil
            end
          end
      end
    end
  end
end
