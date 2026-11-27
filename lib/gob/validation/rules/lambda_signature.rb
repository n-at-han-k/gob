# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Requires Go types on lambda parameters and results.
      class LambdaSignature < Cop
        MSG = "Add a signature comment to the lambda, for example `|value| # (int) -> bool`"

        RESULT = /->/

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
              block: SyntaxTree::BlockNode[block_var: block_var, bodystmt: bodystmt]
            ] if missing_params?(block_var) || missing_result?(block_var, bodystmt)
              add_offense(range(node.location), message: MSG)

            else
              nil
            end
          end

          # A parameter carries no Go type of its own, so a lambda that takes one
          # needs the comment that names it.
          # ---
          def missing_params?(block_var)
            return false unless block_var in { params: SyntaxTree::Params[requireds: [_, *]] }

            !(block_var in { comments: [SyntaxTree::Comment, *] })
          end

          # A returned value needs a result type, which only the `->` half of the
          # signature can give it.
          # ---
          def missing_result?(block_var, bodystmt)
            return false unless returns_value?(bodystmt)

            !(block_var in { comments: [SyntaxTree::Comment[value: RESULT], *] })
          end

          def returns_value?(node)
            case node
            in SyntaxTree::ReturnNode[arguments: SyntaxTree::Args[parts: [_, *]]]
              true

            in SyntaxTree::Node
              returns_value?(node.child_nodes.compact)

            in [first, *rest]
              returns_value?(first) || returns_value?(rest)

            else
              false
            end
          end
      end
    end
  end
end
