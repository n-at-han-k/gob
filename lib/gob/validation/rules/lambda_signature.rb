# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Requires Go types on lambda parameters and results.
      class LambdaSignature < Cop
        MSG = "Add a signature comment to the lambda, for example `|value| # (int) -> bool`"

        private

          # lambda { |value| value > 0 }
          # lambda { |value| # (int) -> bool
          #   value > 0
          # }
          # ---
          def rule(node)
            case node
            in SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: nil,
                operator: nil,
                message: SyntaxTree::Ident[value: "lambda"]
              ],
              block: SyntaxTree::BlockNode[
                block_var: block_var,
                bodystmt: bodystmt
              ]
            ]
              requireds = block_var&.params&.requireds || []
              comments = block_var&.comments || []
              signature = comments.filter_map { |comment| comment.value if comment.is_a?(SyntaxTree::Comment) }.first
              missing_params = !requireds.empty? && signature.nil?
              missing_result = returns_value?(bodystmt) && !signature&.include?("->")

              add_offense(range(node.location), message: MSG) if missing_params || missing_result

            else
              nil
            end
          end

          def returns_value?(node)
            case node
            in SyntaxTree::ReturnNode[arguments: SyntaxTree::Args[parts: parts]] unless parts.empty?
              true
            in SyntaxTree::Node
              node.child_nodes.any? { |child| returns_value?(child) }
            in Array
              node.any? { |child| returns_value?(child) }
            else
              false
            end
          end
      end
    end
  end
end
