# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Spells a zero-based counting loop with Integer#times.
      class ZeroBasedRangeLoop < Cop
        MSG = "Write `%<count>s.times` for a zero-based counting loop"
        MSG_UNSUPPORTED = "Start a counting loop at zero with `%<count>s.times`"

        private

          # (0...count).each do |i| ... end
          # count.times do |i| ... end
          # ---
          def rule(node)
            case node
            in SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: SyntaxTree::Paren[
                  contents: SyntaxTree::Statements[body: [range]]
                ],
                operator: SyntaxTree::Period[value: "."],
                message: SyntaxTree::Ident[value: "each"]
              ],
              block: SyntaxTree::BlockNode[
                block_var: SyntaxTree::BlockVar[
                  params: SyntaxTree::Params[requireds: [index]]
                ]
              ]
            ] if counting_range?(range)
              count = source(range.right.location)
              add_offense(range(node.location), message: format(MSG, count: count)) do |corrector|
                corrector.replace(range(node.call.location), "#{count}.times")
              end

            in SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: SyntaxTree::Paren[
                  contents: SyntaxTree::Statements[body: [range]]
                ],
                operator: SyntaxTree::Period[value: "."],
                message: SyntaxTree::Ident[value: "each"]
              ]
            ] if exclusive_range?(range)
              add_offense(range(range.location), message: MSG_UNSUPPORTED)

            else
              nil
            end
          end

          def counting_range?(range)
            exclusive_range?(range) && range.left.is_a?(SyntaxTree::Int) && range.left.value == "0"
          end

          def exclusive_range?(range)
            range.is_a?(SyntaxTree::RangeNode) && range.operator.value == "..."
          end
      end
    end
  end
end
