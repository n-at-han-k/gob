# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Switches
        module_function

        def register(matcher)
          matcher.rule(:case_expression) { Matcher::MISS }
          matcher.rule(:type_switch) { Matcher::MISS }
          matcher.rule(:when_clause) { Matcher::MISS }
          matcher.rule(:else_clause) { Matcher::MISS }
        end
      end
    end
  end
end
