# frozen_string_literal: true

require "fileutils"
require "pathname"
require_relative "../base"

module Gob
  class CLI
    module Commands
      class Transpile < Base
        default_command :transpile
        desc "transpile [PATH...]", "Transpile Gob source to Go"
        method_option :output, aliases: "-o", type: :string, desc: "Write Go to FILE, or to DIR for a directory of input"

        # A single file writes to --output, or to stdout without it. A
        # directory of input writes a mirror of itself: `transpile src -o out`
        # puts src/journal/table.gob at out/journal/table.go. Without --output
        # each file writes to its own .go sibling.
        # ---
        def transpile(*paths)
          inputs = inputs_from(*paths)

          if inputs.one? && !tree?(paths)
            file, = inputs.first
            source, path = read_source(file)
            return write_output(transpile_source(source, path), options[:output])
          end

          inputs.each do |file, relative|
            source, path = read_source(file)
            write_output(transpile_source(source, path), destination(file, relative))
          end
        end

        no_commands do
          # Each input file with the path it keeps under --output. A file named
          # directly keeps its basename; a file found inside a directory keeps
          # its path relative to that directory.
          # ---
          def inputs_from(*paths)
            paths = ["."] if paths.empty?

            paths.flat_map { |path|
              if File.directory?(path)
                expand_path(path).map { |file| [file, Pathname(file).relative_path_from(path).to_s] }
              else
                [[path, File.basename(path)]]
              end
            }.uniq
          end

          # Whether any input was given as a directory, which makes --output a
          # directory too even when the directory holds a single file.
          # ---
          def tree?(paths)
            paths.any? { |path| File.directory?(path) }
          end

          # Under --output, the file keeps `relative` so the output mirrors the
          # input tree. Without it, the Go lands next to the Gob it came from.
          # ---
          def destination(file, relative)
            return "#{file.delete_suffix(".gob")}.go" if options[:output].nil?

            go = "#{relative.delete_suffix(".gob")}.go"

            File.join(options[:output], go).tap { |path| FileUtils.mkdir_p(File.dirname(path)) }
          end
        end
      end
    end
  end
end
