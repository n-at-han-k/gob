# frozen_string_literal: true

require "rubocop"
require_relative "offence"

module Gob
  module Validation
    module Rules
      require_relative "rules/cop"
      require_relative "rules/class_rules"
      require_relative "rules/function_rules"
      require_relative "rules/module_rules"
      require_relative "rules/program_rules"

      COPS = [
        ClassRules,
        FunctionRules,
        ModuleRules,
        ProgramRules
      ].freeze

      CONFIG_PATH = File.expand_path("rules/config.yml", __dir__)

      module_function

      def config_store
        @config_store ||= begin
          store = RuboCop::ConfigStore.new
          store.options_config = CONFIG_PATH
          store
        end
      end

      def registry
        @registry ||= RuboCop::Cop::Registry.new(COPS)
      end

      def reset!
        @config_store = nil
        @registry = nil
      end

      def validate(source, path: nil)
        temp_path = path || "gob_check.rb"
        config = config_store.for(temp_path)
        processed_source = RuboCop::ProcessedSource.new(source, config.target_ruby_version, temp_path)
        team = RuboCop::Cop::Team.mobilize(registry, config, { auto_correct: false, stdin: true })

        if team.respond_to?(:investigate)
          result = team.investigate(processed_source)
        else
          result = team.inspect_file(processed_source)
        end

        if result.is_a?(Array)
          result
        else
          result.offenses
        end
      end

      def validate_files(entries, formatter:)
        paths = entries.map(&:last)
        formatter.started(paths)

        begin
          entries.flat_map do |source, path|
            formatter.file_started(path, {})
            offenses = validate(source, path: path)
            formatter.file_finished(path, offenses)
            offenses
          end
        ensure
          formatter.finished(paths)
        end
      end

      def check!(source, path: nil)
        offenses = validate(source, path: path)
        return offenses if offenses.empty?
        first = offenses.first

        raise Gob::Validation::Offence.new(
          first.message,
          path: path || "gob_check.rb",
          line: first.line,
          column: first.column,
          cop: first.cop_name
        )
      end
    end
  end
end
