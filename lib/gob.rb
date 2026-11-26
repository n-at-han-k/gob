# frozen_string_literal: true

require "syntax_tree"
require "syntax_tree/go"

require_relative "gob/version"
require_relative "gob/reporter"
require_relative "gob/transpilation/context"
require_relative "gob/transpilation/runner"
require_relative "gob/validation/rules"
require_relative "gob/go/printer"

module Gob

  #
  # Artist: Gio
  # Url: https://asciiart.website/art/6033
  #
  GOBBY = <<-'____'
                             ;=\_|)_
      gob                   ,\   o  '-/_
                 ________ ;'  <      Y/
              _-'        '        _.'=
             /                   /
  _=--     _/             _\  | ;
  -=______/ _         _===  \ \/
        --"-' '--==== --"-   ""-
  ____

  # Parse `source` and transpile it into a SyntaxTree::Go tree.
  def self.transpile(source, path: nil, check: true)
    Validation::Rules.check!(source, path: path) if check
    Transpilation::Context.global_for(path) if path
    Transpilation::Runner.new.call(SyntaxTree.parse(source))
  end

  # Transpile `source` and emit it as Go source text.
  def self.transpile_to_go(source, path: nil, check: true)
    Go::Printer.print(transpile(source, path: path, check: check))
  end
end
