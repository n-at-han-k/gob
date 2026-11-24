# frozen_string_literal: true

require_relative "../base"

module Gob
  class CLI
    module Commands
      class Fmt < Base
        default_command :fmt

        desc "fmt FILE...", "Format Gob source"
        method_option :write, aliases: "-w", type: :boolean, default: false, desc: "Write formatted source back to FILE"

        def fmt(*files)
          files_from(*files)

          files.each do |file|
            source, = read_source(file)
            formatted = SyntaxTree.format(source)

            if options[:write]
              raise Thor::Error, "Cannot use --write with stdin" if file == "-"

              File.write(file, formatted)
            else
              $stdout.write(formatted)
            end
          end
        end
      end
    end
  end
end
