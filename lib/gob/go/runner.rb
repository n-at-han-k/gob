# frozen_string_literal: true

require "fileutils"
require "tmpdir"

require_relative "../reporter"

module Gob
  module Go
    module Runner
      module_function

      def run(source, args: [])
        with_source(source) do |path|
          execute("go", "run", path, *args)
        end
      end

      def build(source, output:)
        FileUtils.mkdir_p(File.dirname(output))

        with_source(source) do |path|
          execute("go", "build", "-o", File.expand_path(output), path)
        end
      end

      def mod_init(module_path = nil)
        execute("go", "mod", "init", *[module_path].compact)
      end

      def with_source(source)
        Dir.mktmpdir("gob-") do |directory|
          path = File.join(directory, "main.go")
          File.write(path, source)
          yield path
        end
      end

      # Runs `command` with inherited streams so the Go toolchain's output
      # arrives as it is produced rather than after the process exits.
      def execute(*command)
        Gob::Reporter.step(command.join(" "))
        system(*command)
      end
    end
  end
end
