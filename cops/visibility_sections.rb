# frozen_string_literal: true

module RuboCop
  module Cop
    module Transpile
      # Turns the emitter's per-definition visibility markers into one section.
      #
      # Ast::DSL's `Function` writes the visibility inline on every definition,
      # public ones included, because it sees one Go function at a time and
      # cannot know where that function will sit in the body:
      #
      #   private def self.runMetrics
      #   end
      #   public def main
      #   end
      #
      # Having BOTH markers on every definition is what makes this correctable.
      # The cop can read each definition's visibility off the source, so it can
      # reorder the body, drop the markers and leave a single `private`:
      #
      #   def main
      #   end
      #
      #   private
      #
      #   def self.runMetrics
      #   end
      #
      # Indentation under the `private` is not this cop's business:
      # Layout/IndentationConsistency with indented_internal_methods owns it and
      # runs after.
      #
      # Public definitions keep their order relative to each other, and so do
      # private ones. Only the two groups move.
      class VisibilitySections < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Group the definitions by visibility under a single `private`.'

        # `private def ...` -- the modifier applied to a definition. The bare
        # `private` section form has no argument and is the shape this produces,
        # so it is not matched and the cop does not fire on its own output.
        def_node_matcher :visibility_def?, <<~PATTERN
          (send nil? {:public :private} ({def defs} ...))
        PATTERN

        # Hooked on the containers rather than on `begin`. A body holding ONE
        # statement is not a begin node -- it is that statement -- and most of
        # these files declare a single function, so an on_begin cop saw nothing
        # in them and left the inline markers in place.
        def on_module(node)
          body = node.body
          return if body.nil?

          group(body.begin_type? ? body.children : [body])
        end
        alias on_class on_module
        alias on_sclass on_module

        private

          def group(children)
            units = children.select { visibility_def?(_1) }
            return if units.empty?
            return unless contiguous?(children, units)

            public_units, private_units = units.partition { _1.method_name == :public }

            add_offense(units.first, message: MSG) do |corrector|
              corrector.replace(span(units), rebuilt(public_units, private_units, indent(units.first)))
            end
          end

          # Only a run of definitions is safe to reorder. A constant or an
          # assignment sitting between them has to stay where it is -- a Go
          # package-level var is read by the functions below it.
          def contiguous?(children, units)
            first = children.find_index { _1.equal?(units.first) }
            last = children.find_index { _1.equal?(units.last) }

            children[first..last].all? { visibility_def?(_1) }
          end

          # From the first unit's own comments to the last unit's final line.
          def span(units)
            starts = comments_above(units.first).first&.source_range || units.first.source_range
            range_by_whole_lines(starts.join(units.last.source_range), include_final_newline: false)
          end

          def rebuilt(public_units, private_units, pad)
            sections = []
            sections << public_units.map { unit_text(_1) }.join("\n\n") if public_units.any?
            sections << "#{pad}private\n\n#{private_units.map { unit_text(_1) }.join("\n\n")}" if private_units.any?

            sections.join("\n\n")
          end

          # The unit's comments and its definition, with the marker removed from
          # the line the definition starts on.
          def unit_text(unit)
            comments = comments_above(unit).map { range_by_whole_lines(_1.source_range).source }
            body = range_by_whole_lines(unit.source_range).source
                                                          .sub(/\A(\s*)#{unit.method_name}[ \t]+/) { Regexp.last_match(1) }

            (comments + [body]).join("\n")
          end

          def indent(node) = ' ' * node.source_range.column

          # Contiguous comment lines immediately above, stopping at the first
          # line that is not one.
          def comments_above(node)
            line = node.source_range.line - 1
            found = []

            while (comment = comment_at(line))
              found.unshift(comment)
              line -= 1
            end

            found
          end

          def comment_at(line)
            processed_source.comments.find { _1.source_range.line == line }
          end
      end
    end
  end
end
