# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Uses the goroutine lambda form understood by the transpiler.
      class GoCall < Cop
        MSG = "Write `go lambda { ... }.()`"

        private

          # go srv.Accept(listener)
          # go lambda { srv.Accept(listener) }.()
          # ---
          def rule(node)
            case node
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "go"],
              arguments: SyntaxTree::Args[parts: [call]]
            ] unless lambda_call?(call)
              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), replacement(node, call))
              end

            else
              nil
            end
          end

          def lambda_call?(call)
            call in SyntaxTree::CallNode[
              receiver: SyntaxTree::MethodAddBlock[
                call: SyntaxTree::CallNode[
                  receiver: nil,
                  operator: nil,
                  message: SyntaxTree::Ident[value: "lambda"]
                ]
              ],
              operator: SyntaxTree::Period[value: "."],
              message: :call
            ]
          end

          # The column a node starts at is the indentation it was written with.
          # ---
          def replacement(node, call)
            node.location => { start_column: indent }

            "go lambda {\n#{" " * (indent + 2)}#{source(call.location)}\n#{" " * indent}}.()"
          end
      end
    end
  end
end
