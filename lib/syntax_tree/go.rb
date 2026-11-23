# frozen_string_literal: true

require "prettier_print"
require "syntax_tree"

#require_relative "go/nodes"
#require_relative "go/parser"
#require_relative "go/visitor"
#
#require_relative "go/evaluate"
#require_relative "go/format"
#require_relative "go/pretty_print"

module SyntaxTree
  module Go
    def self.format(source, maxwidth = 80)
      PrettierPrint.format(+"", maxwidth) { |q| parse(source).format(q) }
    end

    def self.parse(source)
      Parser.new(source).parse
    end

    def self.read(source)
      File.read(source)
    end
  end

  register_handler(".go", Go)
end
