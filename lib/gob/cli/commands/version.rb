# frozen_string_literal: true

require_relative "../base"
require_relative "../../version"

module Gob
  class CLI
    module Commands
      class Version < Base
        default_command :version
        desc "version", "Print Gob version"

        def version
          puts Gob::VERSION
        end
      end
    end
  end
end
