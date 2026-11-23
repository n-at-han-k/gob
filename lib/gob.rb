# frozen_string_literal: true

require_relative "gob/transpiler"
require_relative "gob/rules/core"
require_relative "gob/go/printer"

module Gob
  def self.default_matcher
    @default_matcher ||= begin
      matcher = Matcher.new
      Rules.register(matcher)
      matcher
    end
  end

  def self.transpile(source)
    Transpiler.new.transpile(source)
  end

  def self.transpile_to_go(source)
    Go::Printer.print(transpile(source))
  end
end
