# frozen_string_literal: true

require_relative "../base"

module Gob
  class CLI
    module Commands
      class Transpile < Base
        default_command :transpile

        desc "transpile FILE", "Transpile Gob source to Go"
        method_option :output, aliases: "-o", type: :string, desc: "Write Go source to FILE"

        def transpile(file)
          source, path = read_source(file)
          write_output(transpile_source(source, path), options[:output])
        end
      end
    end
  end
end
