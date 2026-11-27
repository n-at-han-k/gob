# frozen_string_literal: true

require_relative "../base"

module Gob
  class CLI
    module Commands
      class Fmt < Base
        default_command :fmt
        desc "fmt [PATH...]", "Format Gob source in place"

        # fmt is the write command: it formats each file where it sits, the way
        # `gofmt -w` and `go fmt` do. Reading stdin has nowhere to write back
        # to, so that one case prints to stdout.
        # ---
        def fmt(*paths)
          files_from(*paths).each do |file|
            source, path = read_source(file)
            formatted = Gob::Validation::Rules.autocorrect(source, path: path)

            if file == "-"
              $stdout.write(formatted)
            else
              File.write(file, formatted) unless formatted == source
            end
          end
        end
      end
    end
  end
end
