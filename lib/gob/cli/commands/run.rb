# frozen_string_literal: true

require_relative "../base"
require_relative "../../go/runner"

module Gob
  class CLI
    module Commands
      class Run < Base
        default_command :execute

        desc "run FILE [ARGS...]", "Transpile and run a Gob program"

        def execute(file, *args)
          source, path = read_source(file)
          go_source = transpile_source(source, path)
          exit 1 unless Gob::Go::Runner.run(go_source, args: args)
        end
      end
    end
  end
end
