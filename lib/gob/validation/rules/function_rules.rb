# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class FunctionRules < Cop
        MSG = "Disallowed construct in function: `%<name>s`"

        DISALLOWED_TYPES = %i[
          rescue
          resbody
          ensure
          retry
          redo
        ].freeze
        def on_def(node)
          check_body(node)
        end

        alias on_defs on_def

        private

          def check_body(node)
            node.each_descendant do |child|
              next unless DISALLOWED_TYPES.include?(child.type)
              add_offense(child.loc.keyword || child.loc.expression, message: format(MSG, name: child.type))
            end
          end
      end
    end
  end
end
