# frozen_string_literal: true

require_relative "program"
require_relative "misc"
require_relative "literals"
require_relative "references"
require_relative "operators"
require_relative "calls"
require_relative "indexing"
require_relative "assignments"
require_relative "declarations"
require_relative "types"
require_relative "functions"
require_relative "conditionals"
require_relative "loops"
require_relative "switches"
require_relative "blocks"
require_relative "concurrency"
require_relative "fallback"

module Gob
  module Transpilation
    module Rules
      module_function

      def const_go_name(name)
        parts = name.to_s.split("_").reject(&:empty?)
        return name.to_s.downcase if parts.length <= 1

        parts.first.downcase + parts.drop(1).map(&:capitalize).join
      end

      def register(matcher)
        Program.register(matcher)
        Misc.register(matcher)
        Literals.register(matcher)
        References.register(matcher)
        Operators.register(matcher)
        Calls.register(matcher)
        Types.register(matcher)
        Indexing.register(matcher)
        Assignments.register(matcher)
        Concurrency.register(matcher)
        Declarations.register(matcher)
        Functions.register(matcher)
        Conditionals.register(matcher)
        Loops.register(matcher)
        Switches.register(matcher)
        Blocks.register(matcher)
        Fallback.register(matcher)
      end
    end
  end
end
