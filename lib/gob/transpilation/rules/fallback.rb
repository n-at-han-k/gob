# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Fallback
        module_function

        def register(matcher)
          matcher.rule(:drop_unimplemented) do |node|
            node => SyntaxTree::Node

            Matcher::DROP
          end
        end
      end
    end
  end
end
