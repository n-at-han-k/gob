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
                  contents: SyntaxTree::Statements[body: [SyntaxTree::RangeNode[
                    left: SyntaxTree::Int[value: "0"],
                    operator: { value: "..." },
                    right: count
                  ]]]
                ],
                operator: SyntaxTree::Period[value: "."],
                message: SyntaxTree::Ident[value: "each"]
              ] => call,
              block: SyntaxTree::BlockNode[
                block_var: SyntaxTree::BlockVar[
                  params: SyntaxTree::Params[requireds: [_]]
                ]
              ]
            ]
              add_offense(range(node.location), message: format(MSG, count: source(count.location))) do |corrector|
                corrector.replace(range(call.location), "#{source(count.location)}.times")
              end

            # A range that starts anywhere else counts from the wrong place, and
            # there is no Gob spelling for it.
            # ---
            in SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: SyntaxTree::Paren[
                  contents: SyntaxTree::Statements[body: [SyntaxTree::RangeNode[
                    operator: { value: "..." },
                    right: count
                  ] => range]]
                ],
                operator: SyntaxTree::Period[value: "."],
                message: SyntaxTree::Ident[value: "each"]
              ]
            ]
              add_offense(range(range.location), message: format(MSG_UNSUPPORTED, count: source(count.location)))

            else
              nil
            end
          end
      end
    end
  end
end
