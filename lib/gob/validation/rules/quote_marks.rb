# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class QuoteMarks < Cop
        MSG = "Single quotes are a rune; use double quotes for text"

        # One character, or one escape of a character. Go spells an escape as
        # `\n`, `\x41`, `\101`, `\u0041` or `\U0001F600`, and each of them is
        # still a single rune however many characters it takes to write.
        RUNE = %r{
          \A
          (?:
            \\ (?: x\h{2} | u\h{4} | U\h{8} | [0-7]{3} | . )
            |
            [^\\]
          )
          \z
        }mx

        private

          # A rune is one character. Anything longer is text written the wrong
          # way, and SyntaxTree already knows which quote the literal wore.
          #
          # 'hello'
          # "hello"
          # ---
          def rule(node)
            case node
            in SyntaxTree::StringLiteral[
              quote: "'",
              parts: [SyntaxTree::TStringContent[value: text]]
            ] unless text in RUNE
              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), text.inspect)
              end

            else
              nil
            end
          end
      end
    end
  end
end
