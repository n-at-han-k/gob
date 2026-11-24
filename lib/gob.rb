# frozen_string_literal: true

require_relative "gob/transpiler"
require_relative "gob/rules/core"
require_relative "gob/rules/offences"
require_relative "gob/go/printer"

module Gob
  def self.default_matcher
    @default_matcher ||= begin
      matcher = Matcher.new
      Rules.register(matcher)
      matcher
    end
  end

  def self.transpile(source, path: nil, check: true)
    Rules::Offences.check!(source, path: path) if check
    Transpiler.new.transpile(source)
  end

  def self.transpile_to_go(source, path: nil, check: true)
    Go::Printer.print(transpile(source, path: path, check: check))
  end
end
