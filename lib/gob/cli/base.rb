# frozen_string_literal: true

require "thor"
require "gob"
require "go_formatter"

module Gob
  class CLI
    class Base < Thor
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
          validate_source!(source, path)
          ast = Gob::Transpiler.new.transpile(source)
          GoFormatter.format(Gob::Go::Printer.print(ast))
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
