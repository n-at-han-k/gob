# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Keeps struct tags attached to their field in the SyntaxTree AST.
      class StructTagPosition < Cop
        MSG = "Put the struct tag comment before the field"
        TAG = /\A#\s*`/

        private

          # Tags: Array[string], # `xml:"tags>tag"`
          # # `xml:"tags>tag"`
          # Tags: Array[string],
          # ---
          def rule(node)
            case node
            in SyntaxTree::CallNode[
              receiver: SyntaxTree::VarRef[value: SyntaxTree::Const[value: "Struct"]],
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "new"],
              arguments: SyntaxTree::ArgParen[
                arguments: SyntaxTree::Args[
                  parts: [SyntaxTree::BareAssocHash[assocs: assocs]],
                  comments: comments
                ]
              ]
            ]
              comments.each do |comment|
                next unless comment.is_a?(SyntaxTree::Comment) && comment.value.match?(TAG)

                misplaced(comment, assocs)
              end

            else
              nil
            end
          end

          def misplaced(comment, assocs)
            assoc = assocs.find { |field| field.location.end_line == comment.location.start_line }
            return if assoc.nil?

            add_offense(range(comment.location), message: MSG) do |corrector|
              corrector.replace(inline_range(comment, assoc), inline_replacement(comment, assoc))
            end
          end

          def inline_range(comment, assoc)
            raw = processed_source.raw_source
            opening = raw.rindex("\n", assoc.location.start_char - 1).then { |index| index ? index + 1 : 0 }

            Parser::Source::Range.new(
              processed_source.buffer,
              opening,
              comment.location.end_char
            )
          end

          def inline_replacement(comment, assoc)
            raw = processed_source.raw_source
            indent = " " * assoc.location.start_column
            field = raw[assoc.location.start_char...comment.location.start_char].rstrip

            "#{indent}#{comment.value}\n#{indent}#{field}"
          end
      end
    end
  end
end
