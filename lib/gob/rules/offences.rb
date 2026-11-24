# frozen_string_literal: true

module Gob
  class Offence < StandardError
    attr_reader :path, :line, :column, :cop, :message_text

    def initialize(message, path: nil, line: nil, column: nil, cop: nil)
      @path = path
      @line = line
      @column = column
      @cop = cop
      @message_text = message
      loc = [path, line, column].compact.join(":")
      super(loc.empty? ? message : "#{loc}: #{message}")
    end
  end

  module Rules
    module Offences
      module_function

      MODULE_WHITELIST = %w[
        require define_const const define_var var attr_accessor
        private public protected module_function include extend prepend
      ].freeze

      CLASS_WHITELIST = %w[
        define_const const define_var var attr_accessor
        private public protected include extend prepend
      ].freeze

      TOP_LEVEL_WHITELIST = %w[
        require private public protected define_const const define_var var
      ].freeze

      def check!(source, path: nil)
        require "rubocop"
        require_relative "../../rubocop/gob/config_loader"

        temp_path = path || "gob_check.rb"
        config_store = RuboCop::Gob::ConfigLoader.config_store
        config = config_store.for(temp_path)
        processed_source = RuboCop::ProcessedSource.new(source, config.target_ruby_version, temp_path)

        team = RuboCop::Cop::Team.mobilize(RuboCop::Cop::Registry.global, config, { auto_correct: false, stdin: true })
        result = if team.respond_to?(:investigate)
                   team.investigate(processed_source)
                 else
                   team.inspect_file(processed_source)
                 end
        offenses = result.is_a?(Array) ? result : result.offenses
        offenses = offenses.select { |o| o.cop_name.start_with?("Gob/") }
        return true if offenses.empty?

        first = offenses.first
        raise Gob::Offence.new(
          first.message,
          path: temp_path,
          line: first.line,
          column: first.column,
          cop: first.cop_name
        )
      end
    end
  end
end
