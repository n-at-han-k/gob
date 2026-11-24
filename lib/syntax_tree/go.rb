# frozen_string_literal: true

require "syntax_tree"
require "gipper"

require_relative "go/node"
require_relative "go/nodes"
require_relative "go/dsl"
require_relative "go/visitor"
require_relative "go/format"
require_relative "go/pretty_print_visitor"
require_relative "go/json_visitor"
require_relative "go/match_visitor"
require_relative "go/materializer"

module SyntaxTree
  module Go
    def self.format(source, maxwidth = 80, options: nil)
      PrettierPrint.format(+"", maxwidth) { |q| parse(source).format(q) }
    end

    def self.parse(source)
      result = Gipper.parse_file(source)
      file = result["file"]
      raise SyntaxTree::Parser::ParseError.new(result["error"] || "Gipper returned no file", 0, 0) if file.nil?

      Materializer.materialize(file)
    end

    def self.read(filepath)
      ::File.read(filepath)
    end
  end

  register_handler(".go", Go)
end

# Patch Go nodes so CLI `stree json` (which uses SyntaxTree::JSONVisitor)
# works with Go node accept methods.
SyntaxTree::Go.constants.each do |name|
  klass = SyntaxTree::Go.const_get(name)
  next unless klass.is_a?(Class) && klass < SyntaxTree::Go::Node

  klass.class_eval do
    alias_method :__go_accept, :accept
    define_method(:accept) do |visitor|
      if defined?(SyntaxTree::JSONVisitor) &&
           visitor.is_a?(SyntaxTree::JSONVisitor) &&
           !visitor.is_a?(SyntaxTree::Go::JSONVisitor)
        return SyntaxTree::Go::JSONVisitor.new.visit(self)
      end

      __go_accept(visitor)
    end
  end
end
