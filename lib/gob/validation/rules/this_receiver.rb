# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Uses the receiver name emitted by Gob's method definitions.
      class ThisReceiver < Cop
        MSG = "Write `%<replacement>s`, not `%<original>s`"

        private

          # this.Value
          # self.Value
          # @this = value
          # @self = value
          # ---
          def rule(node)
            case node
            in SyntaxTree::VCall[value: SyntaxTree::Ident[value: "this" => original]]
              replace(node, original, "self")

            in SyntaxTree::IVar[value: "@this"]
              replace(node, "@this", "@self")

            else
              nil
            end
          end

          def replace(node, original, replacement)
            add_offense(range(node.location), message: format(MSG, original: original, replacement: replacement)) do |corrector|
              corrector.replace(range(node.location), replacement)
            end
          end
      end
    end
  end
end
