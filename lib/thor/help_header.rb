# frozen_string_literal: true

require "thor"
require "gob"

class Thor
  class << self
    alias_method :help_without_gob_header, :help
    alias_method :command_help_without_gob_header, :command_help

    def help(shell, subcommand = false)
      shell.say Gob::GOBBY
      shell.say ""
      help_without_gob_header(shell, subcommand)
    end

    def command_help(shell, command)
      shell.say Gob::GOBBY
      shell.say ""
      command_help_without_gob_header(shell, command)
    end
  end
end
