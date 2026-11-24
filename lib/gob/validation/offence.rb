# frozen_string_literal: true

module Gob
  module Validation
    class Offence < StandardError
      attr_reader :path, :line, :column, :cop, :message_text

      def initialize(message, path: nil, line: nil, column: nil, cop: nil)
        @path = path
        @line = line
        @column = column
        @cop = cop
        @message_text = message
        location = [path, line, column].compact.join(":")

        if location.empty?
          super(message)
        else
          super("#{location}: #{message}")
        end
      end
    end
  end
end
