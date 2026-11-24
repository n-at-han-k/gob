# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Concurrency
        module_function

        def register(matcher)
          matcher.rule(:defer) { Matcher::MISS }
          matcher.rule(:go) { Matcher::MISS }
          matcher.rule(:send) { Matcher::MISS }
          matcher.rule(:select) { Matcher::MISS }
          matcher.rule(:receive) { Matcher::MISS }
        end
      end
    end
  end
end
