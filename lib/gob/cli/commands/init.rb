# frozen_string_literal: true

require_relative "../base"
require_relative "../../go/runner"

module Gob
  class CLI
    module Commands
      class Init < Base
        default_command :init
        desc "init [MODULE]", "Initialise a Go module (go.mod)"
        long_desc "Writes a go.mod file by running `go mod init`. When MODULE is omitted, Go infers the module path from .go import comments or GOPATH."

        def init(module_path = nil)
          exit 1 unless Gob::Go::Runner.mod_init(module_path)
        end
      end
    end
  end
end
