# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Rejects immediately invoked lambdas except Gob's supported goroutine form.
      class InvokedLambda < Cop
        MSG = "Do not invoke a lambda immediately; only `go lambda { ... }.()` is supported"

        private

          # lambda { work }.()
          # go lambda { work }.()
          # ---
          def rule(node)
            case node
            in SyntaxTree::CallNode[
              receiver: SyntaxTree::MethodAddBlock[
                call: SyntaxTree::CallNode[
                  receiver: nil,
                  operator: nil,
                  message: SyntaxTree::Ident[value: "lambda"]
                ]
              ],
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "call"] | :call
            ]
              add_offense(range(node.location), message: MSG) unless goroutine_argument?

            else
              nil
            end
          end

          def goroutine_argument?
            @ancestors&.any? do |ancestor|
              case ancestor
              in SyntaxTree::Command[message: SyntaxTree::Ident[value: "go"]]
                true
              else
                false
              end
            end
          end
      end
    end
  end
end
