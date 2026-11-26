# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Uses Gob's class-variable spelling for Go pointer types.
      class PointerType < Cop
        MSG = "Write `@@Type` for a pointer type, not `ptr(Type)`"

        private

          # ptr(NotFoundError)
          # @@NotFoundError
          # ---
          def rule(node)
            case node
            in SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: "ptr"],
              arguments: SyntaxTree::ArgParen[
                arguments: SyntaxTree::Args[parts: [type]]
              ]
            ]
              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), "@@#{source(type.location)}")
              end

            else
              nil
            end
          end
      end
    end
  end
end
