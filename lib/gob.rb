# frozen_string_literal: true

require_relative "gob/transpiler"
require_relative "gob/transpilation/rules/core"
require_relative "gob/validation/rules"
require_relative "gob/go/printer"

module Gob

  #
  # Artist: Gio
  # Url: https://asciiart.website/art/6033
  #
  GOBBY = <<-____
                             ;=\_|)_
      gob                   ,\   o  '-/_
                 ________ ;'  <      Y/
              _-'        '        _.'=
             /                   /
  _=--     _/             _\  | ;
  -=______/ _         _===  \ \/
        --"-' '--==== --"-   ""-
  ____

  def self.transpile(source, path: nil)
    Validation::Rules.check!(source, path: path)
    Transpiler.new.transpile(source)
  end

  def self.transpile_to_go(source, path: nil, check: true)
    Go::Printer.print(transpile(source, path: path, check: check))
  end
end
