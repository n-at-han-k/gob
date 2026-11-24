# frozen_string_literal: true

require "pathname"
require "minitest/reporters"
require "diff/lcs"
require "diff/lcs/hunk"

module Gob
  class TranspileMismatch < Minitest::Assertion
    attr_reader :gob_path, :expected_path, :emitted_path, :expected, :actual

    def initialize(gob_path:, expected_path:, emitted_path:, expected:, actual:)
      @gob_path = gob_path
      @expected_path = expected_path
      @emitted_path = emitted_path
      @expected = expected
      @actual = actual
      super("Generated Go differs for #{gob_path}")
    end
  end

  class TranspileReporter < Minitest::Reporters::DefaultReporter
    def print_failure(test)
      failure = test.failure

      if failure.nil? || failure.message.strip.empty?
        return
      end

      if test.error?
        puts "❌ Error: #{test.class}##{test.name}"
      else
        puts "❌ Fail: #{test.class}##{test.name}"
      end

      if failure.is_a?(TranspileMismatch)
        print_mismatch(failure)
      else
        print_error(failure.message)
      end

      if @show_test_location
        path, line = test.source_location
        relative = Pathname.new(path).relative_path_from(Pathname.new(Dir.pwd))
        puts "\n#{relative}:#{line}"
      end

      separator
    end

    def on_report
      self.failures += results.count { |result| result.failure.is_a?(TranspileMismatch) }
      super
    end

    private

      def print_mismatch(failure)
        puts ""
        puts "\e[1;31mEXPECTED\e[0m #{red(failure.expected_path)}"
        puts "\e[1;32mEMITTED\e[0m #{green(failure.emitted_path)}"
        puts ""
        hunks = build_hunks(failure.expected.lines, failure.actual.lines)

        hunks.each_with_index do |hunk, index|
          print_message(hunk.diff(:unified, index == hunks.length - 1))
        end
      end

      def build_hunks(old_lines, new_lines)
        pieces = Diff::LCS.diff(old_lines, new_lines)
        hunks = []
        file_length_difference = 0

        pieces.each do |piece|
          hunk = Diff::LCS::Hunk.new(old_lines, new_lines, piece, 3, file_length_difference)
          file_length_difference = hunk.file_length_difference

          if hunk.overlaps?(hunks.last)
            hunk.merge(hunks.last)
            hunks[-1] = hunk
          else
            hunks << hunk
          end
        end

        hunks
      end

      def print_error(message)
        puts ""
        lines = message.lines
        first = lines.shift

        if first
          puts red(first.chomp)
        end

        lines.each { |line| puts grey(line.chomp) }
      end

      def grey(text)
        "\e[90m#{text}\e[0m"
      end

      def print_message(message)
        message.each_line do |line|
          text = line.chomp

          case text
          when /\A@@ /
            puts cyan(text)
          when /\A-/
            puts color_line(text, :red)
          when /\A\+/
            puts color_line(text, :green)
          else
            puts grey(text)
          end
        end
      end

      def color_line(text, foreground)
        match = text.match(/\A(.*?)([ \t]+)\z/)

        if match
          content, whitespace = match.captures
          "#{send(foreground, content)}\e[43m\e[30m#{whitespace}\e[0m"
        else
          send(foreground, text)
        end
      end

      def separator
        puts cyan("─" * 80)
      end
  end
end
