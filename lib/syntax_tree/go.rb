# frozen_string_literal: true

require "syntax_tree"

require_relative "go/visitor"
require_relative "go/format"
require_relative "go/pretty_print_visitor"
require_relative "go/json_visitor"
require_relative "go/match_visitor"
require_relative "go/node"
require_relative "go/nodes"

module SyntaxTree
  module Go
    def self.format(source, maxwidth = 80)
      PrettierPrint.format(+"", maxwidth) { |q| parse(source).format(q) }
    end

    def self.parse(source)
      raise NotImplementedError, "SyntaxTree::Go.parse is not implemented; this package provides Go AST nodes only"
    end

    def self.read(filepath)
      File.read(filepath)
    end
  end

  register_handler(".go", Go)
end
