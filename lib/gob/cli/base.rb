# frozen_string_literal: true

require "thor"
require "gob"
require "go_formatter"

module Gob
  class CLI
    class Base < Thor
      def self.exit_on_failure?
        true
      end

      no_commands do
        def read_source(path)
          if path == "-"
            [$stdin.read, "stdin"]
          else
            [File.read(path), path]
          end
        end

        def files_from(*paths)
          raise Thor::Error, "No files provided" if paths.empty?

          paths
        end

        def validate_source!(source, path)
          offenses = Gob::Validation::Rules.validate(source, path: path)
          return if offenses.empty?

          Gob::CLI::Errors.render_offenses(offenses, path: path)
          exit 1
        end

        def transpile_source(source, path)
          Gob::Reporter.step("fmt #{path}")
          source = Gob::Validation::Rules.autocorrect(source, path: path)

          Gob::Reporter.step("vet #{path}")
          validate_source!(source, path)

          Gob::Reporter.step("transpile #{path}")
          go_source = Gob.transpile_to_go(source, path: path, check: false)

          Gob::Reporter.step("gofmt #{path}")
          GoFormatter.format(go_source)
        end

        def write_output(output, path)
          if path.nil? || path == "-"
            $stdout.write(output)
          else
            File.write(path, output)
          end
        end
      end
    end
  end
end
