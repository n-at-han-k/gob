# frozen_string_literal: true

require "thor"

module Gob
  class CLI < Thor
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
      Commands::Run.start(args)
    end
    map "run" => "execute"

    desc "transpile FILE", "Transpile Gob source to Go"
    subcommand "transpile", Commands::Transpile

    desc "vet FILE...", "Validate Gob source"
    subcommand "vet", Commands::Vet

    desc "version", "Print Gob version"
    subcommand "version", Commands::Version

    def self.run(argv = ARGV)
      help_arguments = argv.take_while { |argument| argument != "--" }

      if help_arguments.include?("help") || help_arguments.any? { |argument| argument == "--help" || argument == "-h" }
        puts "Gob::GOBBY"
      end

      start(argv)
      0
    rescue StandardError => error
      Errors.render(error)
      1
    end
  end
end
