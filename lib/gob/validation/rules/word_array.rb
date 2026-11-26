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
              values = elements.filter_map do |element|
                source(element.location).inspect if element.is_a?(SyntaxTree::TStringContent)
              end

              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), "Array[string].new(#{values.join(", ")})")
              end

            else
              nil
            end
          end
      end
    end
  end
end
