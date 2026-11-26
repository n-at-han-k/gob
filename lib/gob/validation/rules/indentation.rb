# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class Indentation < Cop
        MSG = "Indent this %<depth>d spaces, not %<actual>d"

        WIDTH = 2

        private

          # Every scope indents its body exactly one level past its opener.
          def rule(node)
            case node
            in SyntaxTree::Program | SyntaxTree::BodyStmt
              nil

            in { bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[ body: body ] ] }
              nest(node, body)
              closes(node)

            in { statements: SyntaxTree::Statements[ body: body ] }
              nest(node, body)
              closes(node)

            else
              nil
            end
          end

          def nest(node, body)
            depth = indentation(node.location) + WIDTH

            body.each do |statement|
              case statement
              in SyntaxTree::VoidStmt
                nil

              else
                misindented(statement, depth)
              end
            end
          end

          def misindented(statement, depth)
            actual = statement.location.start_column
            return if actual == depth
            return unless opens_line?(statement)

            add_offense(range(statement.location), message: format(MSG, depth: depth, actual: actual)) do |corrector|
              corrector.replace(leading(statement.location), " " * depth)
            end
          end

          # `end` lines up with the line that opened the scope.
          def closes(node)
            closer = closer(node)
            return if closer.nil?

            depth = indentation(node.location)
            actual = indentation_of(closer.begin_pos)
            return if actual == depth
            return unless begins_line?(closer.begin_pos)

            add_offense(closer, message: format(MSG, depth: depth, actual: actual)) do |corrector|
              corrector.replace(leading_at(closer.begin_pos), " " * depth)
            end
          end

          def closer(node)
            raw = processed_source.raw_source
            closing = node.location.end_char
            return nil unless raw[(closing - 3)...closing] == "end"

            Parser::Source::Range.new(processed_source.buffer, closing - 3, closing)
          end

          # Only the statement that begins its line owns that line's indentation.
          def opens_line?(location_owner)
            raw = processed_source.raw_source
            start = location_owner.location.start_char
            opening = raw.rindex("\n", start - 1).then { |index| index ? index + 1 : 0 }

            raw[opening...start].match?(/\A[ \t]*\z/)
          end

          # A body is indented past the line its opener sits on, not past the
          # opener itself -- `xs.each do` opens a scope from column 4, not 11.
          def indentation(location)
            raw = processed_source.raw_source
            opening = raw.rindex("\n", location.start_char - 1).then { |index| index ? index + 1 : 0 }

            raw[opening..].match(/\A[ \t]*/)[0].length
          end

          def leading(location)
            leading_at(location.start_char)
          end

          def leading_at(start)
            raw = processed_source.raw_source
            opening = raw.rindex("\n", start - 1).then { |index| index ? index + 1 : 0 }

            Parser::Source::Range.new(processed_source.buffer, opening, start)
          end

          def indentation_of(start)
            leading_at(start).source.length
          end

          def begins_line?(start)
            leading_at(start).source.match?(/\A[ \t]*\z/)
          end
      end
    end
  end
end
