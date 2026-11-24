# frozen_string_literal: true

require_relative "gob/transpiler"
require_relative "gob/transpilation/rules/core"
require_relative "gob/validation/rules"
require_relative "gob/go/printer"

module Gob
  def self.default_matcher
    @default_matcher ||= begin
      matcher = Matcher.new
      Transpilation::Rules.register(matcher)
      matcher
    end
  end

  def self.transpile(source, path: nil, check: true)
    Validation::Rules.check!(source, path: path) if check
    Transpiler.new.transpile(source)
  end

  def self.transpile_to_go(source, path: nil, check: true)
    Go::Printer.print(transpile(source, path: path, check: check))
  end
end
