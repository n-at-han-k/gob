# frozen_string_literal: true

require_relative "../base"
require_relative "../../go/runner"

module Gob
  class CLI
    module Commands
      class Build < Base
        default_command :build
        desc "build FILE", "Transpile and build a Gob program"
        method_option :output, aliases: "-o", type: :string, desc: "Write binary to FILE"

        def build(file)
          source, path = read_source(file)
          go_source = transpile_source(source, path)

          if file == "-"
            output = options[:output] || File.basename("gob", ".gob")
          else
            output = options[:output] || File.basename(file, ".gob")
          end

          exit 1 unless Gob::Go::Runner.build(go_source, output: output)
        end
      end
    end
  end
end
