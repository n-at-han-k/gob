# frozen_string_literal: true

require "thor"
require "thor/help_header"

module Gob
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    def self.run(argv = ARGV)
      start(argv)
      0
    rescue StandardError => error
      Errors.render(error)
      1
    end
  end
end

require_relative "version"
require_relative "cli/errors"
require_relative "cli/base"
require_relative "cli/commands/build"
require_relative "cli/commands/fmt"
require_relative "cli/commands/run"
require_relative "cli/commands/transpile"
require_relative "cli/commands/vet"
require_relative "cli/commands/version"

module Gob
  class CLI < Thor
    desc "build FILE", "Transpile and build a Gob program"
    subcommand "build", Commands::Build
    desc "fmt FILE...", "Format Gob source"
    subcommand "fmt", Commands::Fmt
    desc "run FILE [ARGS...]", "Transpile and run a Gob program"

    def execute(*args)
      command_args, command_options = Thor::Arguments.split(args)
      invoke Commands::Run, command_args, command_options, invoked_via_subcommand: true
    end

    map "run" => "execute"
    desc "transpile FILE", "Transpile Gob source to Go"
    subcommand "transpile", Commands::Transpile
    desc "vet FILE...", "Validate Gob source"
    subcommand "vet", Commands::Vet
    desc "version", "Print Gob version"
    subcommand "version", Commands::Version
  end
end
