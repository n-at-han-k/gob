# frozen_string_literal: true

require_relative "../base"

module Gob
  class CLI
    module Commands
      class Vet < Base
        default_command :vet
        desc "vet FILE...", "Validate Gob source"

        def vet(*files)
          files_from(*files)
          offenses_found = false

          files.each do |file|
            source, path = read_source(file)
            offenses = Gob::Validation::Rules.validate(source, path: path)

            if offenses.empty?
              next
            end

            offenses_found = true
            Gob::CLI::Errors.render_offenses(offenses, path: path)
          end

          exit 1 if offenses_found
        end
      end
    end
  end
end
