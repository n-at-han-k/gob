# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Uses the declaration keyword understood by the transpiler.
      class VariableDeclaration < Cop
        MSG = "Write `var`, not `define_var`"

        private

          # define_var :name, Type
          # var :name, Type
          # ---
          def rule(node)
            case node
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "define_var"] => message,
              arguments: SyntaxTree::Args[parts: [SyntaxTree::SymbolLiteral, *]]
            ]
              add_offense(range(message.location), message: MSG) do |corrector|
                corrector.replace(range(message.location), "var")
              end

            else
              nil
            end
          end
      end
    end
  end
end
