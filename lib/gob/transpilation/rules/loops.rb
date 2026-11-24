# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Loops
        module_function

        def register(matcher)
          matcher.rule(:while_loop) { Matcher::MISS }
          matcher.rule(:until_loop) { Matcher::MISS }
          matcher.rule(:loop_block) { Matcher::MISS }
          matcher.rule(:each_block) { Matcher::MISS }
          matcher.rule(:times_block) { Matcher::MISS }
          matcher.rule(:break) { Matcher::MISS }
          matcher.rule(:next) { Matcher::MISS }
          matcher.rule(:return) { Matcher::MISS }
          matcher.rule(:bare_return) { Matcher::MISS }
        end
      end
    end
  end
end
