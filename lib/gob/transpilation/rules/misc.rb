# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Misc
        module_function

        def register(matcher)
          matcher.rule(:comment) do |node|
            node => SyntaxTree::Comment

            Matcher::DROP
          end

          matcher.rule(:void_statement) do |node|
            node => SyntaxTree::VoidStmt

            Matcher::DROP
          end
        end
      end
    end
  end
end
