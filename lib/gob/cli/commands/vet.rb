# frozen_string_literal: true

require_relative "../base"
require "rubocop/formatter/simple_text_formatter"

module Gob
  class CLI
    module Commands
      class Vet < Base
        default_command :vet
        desc "vet [PATH...]", "Validate Gob source"

        def vet(*paths)
          entries = files_from(*paths).map { |file| read_source(file) }
          formatter = RuboCop::Formatter::SimpleTextFormatter.new($stdout)
          offenses = Gob::Validation::Rules.validate_files(entries, formatter: formatter)
          exit 1 unless offenses.empty?
        end
      end
    end
  end
end
