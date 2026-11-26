# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Requires a Go type for every generated struct field.
      class AttributeType < Cop
        MSG = "Write `attr_accessor :name, Type` so the field has a Go type"

        private

          # attr_accessor :Name
          # attr_accessor :Name, string
          # ---
          def rule(node)
            case node
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "attr_accessor"],
              arguments: SyntaxTree::Args[parts: [SyntaxTree::SymbolLiteral]]
            ]
              add_offense(range(node.location), message: MSG)

            else
              nil
            end
          end
      end
    end
  end
end
