# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "syntax_tree"
require "syntax_tree/go"
require "go_formatter"
require "minitest/autorun"
require "minitest/reporters"
require_relative "../lib/gob/transpilation/context"
require_relative "../lib/gob/transpilation/runner"
require_relative "../lib/gob/go/printer"
require_relative "support/transpile_reporter"

Minitest::Reporters.use! [Gob::TranspileReporter.new(color: true, location: true)]

class TranspilationCheckTest < Minitest::Test
  DEFAULT_PATH = File.expand_path("cases/standard-lib-examples", __dir__)
  PATHS = ENV.fetch("GOB_CASE_PATHS", DEFAULT_PATH).lines.map(&:chomp).freeze

  PAIRS = [].tap do |pairs|
    PATHS.each do |path|
      if File.directory?(path)
        Dir[File.join(path, "**/*.gob")].sort.each do |gob|
          go = gob.sub(/\.gob\z/, ".go")

          if File.file?(go)
            pairs << [gob, go]
          end
        end
      elsif File.file?(path)
        case File.extname(path)
        when ".gob"
          pairs << [path, path.sub(/\.gob\z/, ".go")]
        when ".go"
          pairs << [path.sub(/\.go\z/, ".gob"), path]
        else
          raise ArgumentError, "Expected a .gob file, .go file, or directory: #{path}"
        end
      else
        raise ArgumentError, "Expected a .gob or .go file, or directory: #{path}"
      end
    end

    pairs.uniq!
  end.freeze

  if PAIRS.empty?
    define_method(:test_no_cases_found) { flunk "No .gob/.go pairs found in #{PATHS.join(", ")}" }
  end

  PAIRS.each_with_index do |(gob, go), index|
    test_name = "test_#{index.to_s.rjust(4, "0")}_#{gob.tr("/.", "__")}"

    define_method(test_name) do
      tree = SyntaxTree.parse(File.read(gob))
      Gob::Transpilation::Context.global_for(gob)

      generated_go =
        Gob::Go::Printer.print(
          Gob::Transpilation::Runner.new.call(tree)
        )

      output_path = "#{gob}.out"

      begin
        formatted_go = GoFormatter.format(generated_go)
      rescue GoFormatter::Error
        File.write(output_path, generated_go)
        raise
      end

      File.write(output_path, formatted_go)
      expected_go = File.read(go)
      actual_go = File.read(output_path)
      expected_ast = SyntaxTree::Go.parse(expected_go)
      actual_ast = SyntaxTree::Go.parse(actual_go)
      trees_match = expected_ast === actual_ast

      if trees_match
        assert trees_match
      else
        raise Gob::TranspileMismatch.new(
          gob_path: gob,
          expected_path: go,
          emitted_path: output_path,
          expected: compact_go(expected_go),
          actual: compact_go(actual_go)
        )
      end
    end
  end

  private

    def compact_go(source)
      source.lines.reject { |line| line.strip.empty? }.join
    end
end
