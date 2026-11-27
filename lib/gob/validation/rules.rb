# frozen_string_literal: true

require "rubocop"
require_relative "offence"

module Gob
  module Validation
    module Rules
      require_relative "rules/cop"
      require_relative "rules/block_delimiters"
      require_relative "rules/defer_statement"
      require_relative "rules/indentation"
      require_relative "rules/multiline"
      require_relative "rules/quote_marks"
      require_relative "rules/signature_comment"
      require_relative "rules/trailing_whitespace"
      require_relative "rules/zero_based_range_loop"
      require_relative "rules/word_array"
      require_relative "rules/go_block"
      require_relative "rules/go_call"
      require_relative "rules/redundant_lambda_parentheses"
      require_relative "rules/array_length"
      require_relative "rules/collection_literal"
      require_relative "rules/lambda_signature"
      require_relative "rules/invoked_lambda"
      require_relative "rules/attribute_type"

      COPS = [
        BlockDelimiters,
        DeferStatement,
        Indentation,
        Multiline,
        QuoteMarks,
        SignatureComment,
        TrailingWhitespace,
        ZeroBasedRangeLoop,
        WordArray,
        GoBlock,
        GoCall,
        RedundantLambdaParentheses,
        ArrayLength,
        CollectionLiteral,
        LambdaSignature,
        InvokedLambda,
        AttributeType,
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

      # RuboCop's own inspection loop: it merges the cops' correctors, applies
      # them, and is run again while the source keeps changing, because fixing
      # one layout rule can expose the next.
      PASSES = RuboCop::Runner::MAX_ITERATIONS

      # Layout is corrected before anything reads the source, so that what the
      # transpiler sees is always in house style. In stdin mode RuboCop hands
      # the corrected source back through the options it was given.
      def autocorrect(source, path: nil)
        temp_path = path || "gob_check.rb"
        config = config_store.for(temp_path)
        options = { autocorrect: true, stdin: source }
        team = RuboCop::Cop::Team.mobilize(registry, config, options)

        PASSES.times do
          team.investigate(processed_source(options[:stdin], config, temp_path))
          break unless team.updated_source_file?
        end

        options[:stdin]
      end

      def validate(source, path: nil)
        temp_path = path || "gob_check.rb"
        config = config_store.for(temp_path)
        team = RuboCop::Cop::Team.mobilize(registry, config, { autocorrect: false, stdin: true })

        team.investigate(processed_source(source, config, temp_path)).offenses
      end

      def processed_source(source, config, path)
        RuboCop::ProcessedSource.new(source, config.target_ruby_version, path)
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
