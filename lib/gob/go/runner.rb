# frozen_string_literal: true

require "fileutils"
require "open3"
require "tmpdir"

module Gob
  module Go
    module Runner
      module_function

      def run(source, args: [])
        with_source(source) do |path|
          capture("go", "run", path, *args)
        end
      end

      def build(source, output:)
        FileUtils.mkdir_p(File.dirname(output))

        with_source(source) do |path|
          capture("go", "build", "-o", File.expand_path(output), path)
        end
      end

      def mod_init(module_path = nil)
        capture("go", "mod", "init", *[module_path].compact)
      end

      def with_source(source)
        Dir.mktmpdir("gob-") do |directory|
          path = File.join(directory, "main.go")
          File.write(path, source)
          yield path
        end
      end

      def capture(*command)
        stdout, stderr, status = Open3.capture3(*command)
        $stdout.write(stdout)
        $stderr.write(stderr)
        status.success?
      end
    end
  end
end
