# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Removes spaces and tabs that do not contribute to the source.
      class TrailingWhitespace < Cop
        MSG = "Remove trailing whitespace"

        def on_new_investigation
          source = processed_source.buffer.source
          offset = 0

          source.each_line do |line|
            match = line.match(/[ \t]+(?=\r?\n|\z)/)
            next unless match

            add_offense(whitespace_range(offset, match), message: MSG) do |corrector|
              corrector.remove(whitespace_range(offset, match))
            end

            offset += line.length
          end
        end

        private

          def whitespace_range(offset, match)
            Parser::Source::Range.new(
              processed_source.buffer,
              offset + match.begin(0),
              offset + match.end(0)
            )
          end
      end
    end
  end
end
