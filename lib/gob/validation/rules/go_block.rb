# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Uses the lambda call accepted by the transpiler for goroutines.
      class GoBlock < Cop
        MSG = "Write `go lambda { ... }.()`"

        private

          # go do
          #   work
          # end.()
          # ---
          # go lambda {
          #   work
          # }.()
          # ---
          def rule(node)
            case node
            in SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: nil,
                operator: nil,
                message: SyntaxTree::Ident[value: "go"] => message,
                arguments: SyntaxTree::Args[parts: []]
              ],
              block: SyntaxTree::BlockNode[
                opening: SyntaxTree::Kw[value: "do"] => opening
              ] => block
            ]
              add_offense(range(block.location), message: MSG) do |corrector|
                corrector.replace(range(message.location), "go lambda")
                corrector.replace(range(opening.location), "{")
                corrector.replace(closing(block), invoked?(block) ? "}" : "}.()")
              end

            else
              nil
            end
          end

          def closing(block)
            Parser::Source::Range.new(
              processed_source.buffer,
              block.location.end_char - 3,
              block.location.end_char
            )
          end

          def invoked?(block)
            processed_source.raw_source[block.location.end_char, 3] == ".()"
          end
      end
    end
  end
end
