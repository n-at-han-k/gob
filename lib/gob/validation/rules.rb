# frozen_string_literal: true

require "rubocop"
require_relative "offence"

module Gob
  module Validation
    module Rules
      require_relative "rules/cop"
      require_relative "rules/block_delimiters"
      require_relative "rules/defer_statement"
      require_relative "rules/error_check"
      require_relative "rules/indentation"
      require_relative "rules/multiline"
      require_relative "rules/quote_marks"
      require_relative "rules/signature_comment"

      COPS = [
        BlockDelimiters,
        DeferStatement,
        ErrorCheck,
        Indentation,
        Multiline,
        QuoteMarks,
        SignatureComment
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

      PASSES = 10

      # Layout is corrected before anything reads the source, so that what the
      # transpiler sees is always in house style. Corrections are applied in
      # passes, since fixing one layout rule can expose the next.
      def autocorrect(source, path: nil)
        temp_path = path || "gob_check.rb"
        config = config_store.for(temp_path)

        PASSES.times do
          corrector = merge(correctors(source, temp_path, config))
          break if corrector.nil?

          corrected = corrector.process
          break if corrected == source

          source = corrected
        end

        source
      end

      def correctors(source, path, config)
        processed_source = RuboCop::ProcessedSource.new(source, config.target_ruby_version, path)
        team = RuboCop::Cop::Team.mobilize(registry, config, { autocorrect: true, stdin: true })

        team.investigate(processed_source).correctors.compact.reject(&:empty?)
      end

      # Two rules may reach for the same characters; the first one wins this
      # pass and the other is picked up by the next.
      def merge(correctors)
        return nil if correctors.empty?

        correctors.drop(1).each_with_object(correctors.first) do |corrector, head|
          begin
            head.merge!(corrector)
          rescue Parser::ClobberingError
            nil
          end
        end
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
