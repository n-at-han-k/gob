# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class DeferStatement < Cop
        MSG = "Write `defer expression`, never `defer { expression }`"

        private

          # defer { srv.Close() }
          # defer srv.Close()
          # ---
          def rule(node)
            case node
            in SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[ message: SyntaxTree::Ident[value: "defer"] ],
              block: SyntaxTree::BlockNode[
                bodystmt: SyntaxTree::Statements[ body: [ deferred ] ]
              ]
            ]
              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), "defer #{source(deferred.location)}")
              end

            else
              nil
            end
          end
      end
    end
  end
end
