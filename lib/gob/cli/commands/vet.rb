# frozen_string_literal: true

require_relative "../base"
require "rubocop/formatter/simple_text_formatter"

module Gob
  class CLI
    module Commands
      class Vet < Base
        default_command :vet
        desc "vet FILE...", "Validate Gob source"

        def vet(*files)
          paths = files_from(*files).flat_map do |file|
            if File.directory?(file)
              matches = Dir[File.join(file, "**/*.gob")].sort
              raise Thor::Error, "No .gob files found in #{file}" if matches.empty?

              matches
            else
              [file]
            end
          end.uniq

          entries = paths.map { |file| read_source(file) }
          formatter = RuboCop::Formatter::SimpleTextFormatter.new($stdout)
          offenses = Gob::Validation::Rules.validate_files(entries, formatter: formatter)
          exit 1 unless offenses.empty?
        end
      end
    end
  end
end
