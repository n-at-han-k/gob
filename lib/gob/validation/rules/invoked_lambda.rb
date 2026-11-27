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

          # Only `go` may invoke a lambda where it stands.
          # ---
          def goroutine_argument?
            @ancestors.any? { |ancestor| ancestor in SyntaxTree::Command[message: SyntaxTree::Ident[value: "go"]] }
          end
      end
    end
  end
end
