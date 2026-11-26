# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class ErrorCheck < Cop
        MSG = "Write `err`; the comparison against nil is implied"

        private

          # if err != nil
          # if err
          # ---
          def rule(node)
            case node
            in SyntaxTree::Binary[
              left: SyntaxTree::VCall[value: SyntaxTree::Ident[value: "err"]] |
                    SyntaxTree::VarRef[value: SyntaxTree::Ident[value: "err"]],
              operator: :!=,
              right: SyntaxTree::VarRef[value: SyntaxTree::Kw[value: "nil"]]
            ]
              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), "err")
              end

            else
              nil
            end
          end
      end
    end
  end
end
