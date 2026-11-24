# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Conditionals
        module_function

        def register(matcher)
          matcher.rule(:if_condition) { Matcher::MISS }
          matcher.rule(:if_error_assignment) { Matcher::MISS }
          matcher.rule(:if_discarded_error_assignment) { Matcher::MISS }
          matcher.rule(:if_boolean_assignment) { Matcher::MISS }
          matcher.rule(:if_else) { Matcher::MISS }
          matcher.rule(:elsif) { Matcher::MISS }
          matcher.rule(:unless) { Matcher::MISS }
        end
      end
    end
  end
end
