# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class SignatureComment < Cop
        MSG = "Write a signature comment inline on the `def`, not on its own line"

        SIGNATURE = /\A#\s*(\(|->)/

        private

          # # (string) -> error
          # def work(ctx)
          # ---
          # def work(ctx) # (string) -> error
          # ---
          def rule(node)
            case node
            in SyntaxTree::Statements[ body: body ]
              body.each_cons(2) { |comment, definition| misplaced(comment, definition) }

            else
              nil
            end
          end

          def misplaced(comment, definition)
            case [comment, definition]
            in [SyntaxTree::Comment[value: SIGNATURE => signature], SyntaxTree::DefNode]
              add_offense(range(comment.location), message: MSG) do |corrector|
                corrector.remove(line(comment.location))
                corrector.insert_after(end_of_line(definition.location), " #{signature}")
              end

            else
              nil
            end
          end
      end
    end
  end
end
