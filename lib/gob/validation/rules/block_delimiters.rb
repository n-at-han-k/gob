# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class BlockDelimiters < Cop
        MSG = "Write a `%<name>s` block as `do ... end`; `{ ... }` is not read as logic"

        private

          # demos.each { |k| names = append(names, k) }
          # demos.each do |k| names = append(names, k) end
          # ---
          def rule(node)
            case node
            in SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                message: SyntaxTree::Ident[value: "each" | "times" | "loop" => name]
              ],
              block: SyntaxTree::BlockNode[ opening: SyntaxTree::LBrace => opening ] => block
            ]
              add_offense(range(opening.location), message: format(MSG, name: name)) do |corrector|
                corrector.replace(range(opening.location), "do")
                corrector.replace(closing(block), "end")
              end

            else
              nil
            end
          end

          # The `}` is the last character of the block.
          def closing(block)
            Parser::Source::Range.new(
              processed_source.buffer,
              block.location.end_char - 1,
              block.location.end_char
            )
          end
      end
    end
  end
end
