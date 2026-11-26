# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class QuoteMarks < Cop
        MSG = "Single quotes are a rune; use double quotes for text"

        private

          # 'hello'
          # "hello"
          # ---
          def rule(node)
            case node
            in SyntaxTree::StringLiteral[ parts: [SyntaxTree::TStringContent[value: text]] ] if rune?(node, text)
              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), text.inspect)
              end

            else
              nil
            end
          end

          # A rune is one character; anything longer is text written the wrong way.
          def rune?(node, text)
            source(node.location).start_with?("'") && text.length != 1
          end
      end
    end
  end
end
