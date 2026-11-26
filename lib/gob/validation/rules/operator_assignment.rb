# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Expands Ruby's compound assignment into the binary assignment Gob reads.
      class OperatorAssignment < Cop
        MSG = "Expand the compound assignment into an explicit binary assignment"

        OPERATORS = {
          "+=" => "+",
          "-=" => "-",
          "*=" => "*",
          "/=" => "/",
          "%=" => "%"
        }.freeze

        private

          # total += value
          # total = total + value
          # ---
          def rule(node)
            case node
            in SyntaxTree::OpAssign[
              target: target,
              operator: SyntaxTree::Op[value: operator],
              value: value
            ] if OPERATORS.key?(operator)
              target_source = source(target.location)
              replacement = "#{target_source} = #{target_source} #{OPERATORS.fetch(operator)} #{source(value.location)}"

              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), replacement)
              end

            else
              nil
            end
          end
      end
    end
  end
end
