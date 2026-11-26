# frozen_string_literal: true

require "thor"
require "thor/help_header"
require "thor/completion"

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

require_relative "cli/completion"
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
    desc "completion", "Generate shell completion script"

    option :shell,
      type: :string,
      required: true,
      enum: %w[bash zsh fish]
    def completion
      puts Gob::CLI::Completion.generate(
        name: "gob",
        description: "Transpile Gob source to Go",
        version: Gob::VERSION,
        cli: self.class,
        shell: options.shell
      )
    end

    desc "fmt FILE...", "Format Gob source"
    subcommand "fmt", Commands::Fmt
    desc "run FILE [ARGS...]", "Transpile and run a Gob program"

    def _run(file, *args)
      command_args, command_options = Thor::Arguments.split([file, *args])
      invoke Commands::Run, command_args, command_options, invoked_via_subcommand: true
    end

    map "run" => "_run"
    desc "transpile FILE", "Transpile Gob source to Go"
    subcommand "transpile", Commands::Transpile
    desc "vet FILE...", "Validate Gob source"
    subcommand "vet", Commands::Vet
    desc "version", "Print Gob version"
    subcommand "version", Commands::Version
  end
end
