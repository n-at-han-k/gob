# frozen_string_literal: true

require "pathname"
require "minitest/reporters"
require "pp"

module Gob
  class SyntaxMismatch < Minitest::Assertion
    attr_reader :source, :ruby_ast, :expected, :expected_ast, :emitted, :emitted_ast

    def initialize(source:, ruby_ast:, expected:, expected_ast:, emitted:, emitted_ast:)
      @source = source
      @ruby_ast = ruby_ast
      @expected = expected
      @expected_ast = expected_ast
      @emitted = emitted
      @emitted_ast = emitted_ast
      super("Syntax transpilation mismatch")
    end
  end

  class SyntaxReporter < Minitest::Reporters::DefaultReporter
    def print_failure(test)
      failure = test.failure
      return if failure.nil? || failure.message.strip.empty?

      if test.error?
        puts "❌ Error: #{test.class}##{test.name}"
      else
        puts "❌ Fail: #{test.class}##{test.name}"
      end

      if failure.is_a?(SyntaxMismatch)
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
      self.failures += results.count { |result| result.failure.is_a?(SyntaxMismatch) }
      super
    end

    private

      def print_mismatch(failure)
        puts ""
        puts "\e[1;36mRUBY AST\e[0m"
        pp_ast(failure.ruby_ast)
        puts ""
        puts "\e[1;33mEXPECTED AST\e[0m"
        pp_ast(failure.expected_ast)
        puts ""
        puts "\e[1;35mEMITTED AST\e[0m"
        pp_ast(failure.emitted_ast)
      end

      def pp_ast(ast)
        puts format_ast(ast)
      rescue => e
        puts ast.inspect
        puts grey("(format failed: #{e.message})")
      end

      def format_ast(node, indent = 0)
        pad = "  " * indent
        case node
        when Array
          return "[]" if node.empty?
          items = node.map { |n| format_ast(n, indent + 1) }
          "[\n#{items.map { |i| "  #{pad}#{i}," }.join("\n")}\n#{pad}]"
        when SyntaxTree::Node, SyntaxTree::Go::Node
          name = node.class.name
          keys = node.deconstruct_keys(nil)
          skip = %i[location comments start_char end_char start_line end_line start_column end_column]
          keys = keys.reject { |k, _| skip.include?(k) || k.to_s.end_with?("_pos", "_start", "_end") }
          # drop noisy pos/location hashes
          keys = keys.reject { |k, v| v.is_a?(Hash) && v.key?("line") && v.key?("column") }
          keys = keys.reject { |k, v| %i[lbrace rbrace lparen rparen lbrack rbrack opening closing file_start file_end scope imports unresolved go_version package doc tok_pos name_pos].include?(k) }
          if keys.empty?
            name
          else
            parts = keys.map { |k, v| "#{k}: #{format_ast(v, indent + 1)}" }
            if parts.join(", ").length < 60 && !parts.any? { |p| p.include?("\n") }
              "#{name}[#{parts.join(", ")}]"
            else
              "#{name}[\n#{parts.map { |p| "  #{pad}#{p}," }.join("\n")}\n#{pad}]"
            end
          end
        else
          node.inspect
        end
      end

      def print_error(message)
        puts ""
        lines = message.lines
        first = lines.shift
        puts red(first.chomp) if first
        lines.each { |line| puts grey(line.chomp) }
      end

      def grey(text) = "\e[90m#{text}\e[0m"
      def separator = puts cyan("─" * 80)
  end
end
