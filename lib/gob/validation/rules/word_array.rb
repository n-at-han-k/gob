# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Uses an explicitly typed string array instead of Ruby's %w literal.
      class WordArray < Cop
        MSG = "Write `Array[string].new(...)`, not `%w[...]`"

        private

          # %w[one two three]
          # Array[string].new("one", "two", "three")
          # ---
          def rule(node)
            case node
            in SyntaxTree::QWords[elements: elements]
              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), "Array[string].new(#{words(elements).join(", ")})")
              end

            else
              nil
            end
          end

          # The words a %w literal holds, written as Go string literals.
          # ---
          def words(elements)
            case elements
            in []
              []

            in [SyntaxTree::TStringContent[value: word], *rest]
              [ word.inspect, *words(rest) ]

            in [_, *rest]
              words(rest)
            end
          end
      end
    end
  end
end
