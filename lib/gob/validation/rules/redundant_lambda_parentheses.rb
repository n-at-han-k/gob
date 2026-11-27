# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Removes parentheses that hide a lambda from the transpiler.
      class RedundantLambdaParentheses < Cop
        MSG = "Remove parentheses around the lambda"

        private

          # return(lambda do ... end)
          # return lambda do ... end
          # ---
          def rule(node)
            case node
            in SyntaxTree::Paren[
              contents: SyntaxTree::Statements[body: [expression]]
            ] if lambda?(expression)
              add_offense(range(node.location), message: MSG) do |corrector|
                separator = processed_source.raw_source[node.location.start_char - 1]&.match?(/[[:alnum:]_]/) ? " " : ""
                corrector.replace(range(node.location), "#{separator}#{source(expression.location)}")
              end

            else
              nil
            end
          end

          def lambda?(node)
            node in SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: nil,
                operator: nil,
                message: SyntaxTree::Ident[value: "lambda"]
              ]
            ]
          end
      end
    end
  end
end
