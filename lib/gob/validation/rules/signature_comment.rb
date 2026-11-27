# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class SignatureComment < Cop
        MSG = "Write a signature comment inline on the `def`, not on its own line"

        # A signature is a parenthesised list of Go types, a `->` result, or
        # both. Prose that happens to open with a bracket is not a signature,
        # however much it looks like one.
        SIGNATURE = /\A#\s*(?:\((?<params>[^()]*)\))?\s*(?<result>->.*)?\z/

        # A parameter is a Go type, or a name and its Go type.
        TYPE = /\A(?:[\w.*\[\]{}]+ )?[\w.*\[\](){}, ]+\z/

        private

          # # (string) -> error
          # def work(ctx)
          # ---
          # def work(ctx) # (string) -> error
          # ---
          def rule(node)
            case node
            in SyntaxTree::Statements[ body: body ]
              misplaced(body)

            else
              nil
            end
          end

          # A signature belongs to the `def` it follows, so the pair is read as
          # a pair and the rest of the body carries on from the `def`.
          # ---
          def misplaced(body)
            case body
            in []
              nil

            in [SyntaxTree::Comment => comment, SyntaxTree::DefNode => definition, *rest] if signature(comment.value)
              add_offense(range(comment.location), message: MSG) do |corrector|
                corrector.remove(line(comment.location))
                corrector.insert_after(end_of_line(definition.location), " #{comment.value}")
              end

              misplaced([definition, *rest])

            in [_, *rest]
              misplaced(rest)
            end
          end

          # The comment, when it reads as a signature and not as a sentence.
          # ---
          def signature(value)
            match = SIGNATURE.match(value)
            return nil if match.nil?
            return nil if match[:params].nil? && match[:result].nil?
            return value unless match[:result].nil?

            params = match[:params].split(",").map(&:strip)
            params.all? { |param| param.match?(TYPE) && param.count(" ") <= 1 } ? value : nil
          end
      end
    end
  end
end
