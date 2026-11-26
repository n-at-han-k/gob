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
            case call
            in SyntaxTree::CallNode[
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
              true
            else
              false
            end
          end

          def replacement(node, call)
            indent = indentation(node.location)
            "go lambda {\n#{" " * (indent + 2)}#{source(call.location)}\n#{" " * indent}}.()"
          end

          def indentation(location)
            raw = processed_source.raw_source
            opening = raw.rindex("\n", location.start_char - 1).then { |index| index ? index + 1 : 0 }
            raw[opening..].match(/\A[ \t]*/)[0].length
          end
      end
    end
  end
end
