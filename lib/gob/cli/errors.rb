# frozen_string_literal: true

module Gob
  class CLI
    module Errors
      module_function

      def render_offenses(offenses, path: nil)
        offenses.each do |offense|
          filename = path || "gob"

          if offense.column
            column = offense.column + 1
          else
            column = nil
          end

          location = [filename, offense.line, column].compact.join(":")
          message = offense.message.sub(/\A#{Regexp.escape(offense.cop_name)}:\s*/, "")
          warn "#{location}: C: #{offense.cop_name}: #{message}"
        end
      end

      def render(error)
        case error
        when Gob::Validation::Offence
          path = error.path || "gob"

          if error.column
            column = error.column + 1
          else
            column = nil
          end

          location = [path, error.line, column].compact.join(":")
          message = error.message_text.sub(/\A#{Regexp.escape(error.cop)}:\s*/, "")
          warn "#{location}: C: #{error.cop}: #{message}"
        when SyntaxTree::Parser::ParseError
          warn "gob: #{error.message}"
        when Gob::Transpiler::UnsupportedNode
          warn "gob: #{error.message}"
        when GoFormatter::Error
          warn "gob: #{error.message}"
        else
          warn "gob: #{error.message}"
        end
      end
    end
  end
end
