# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class Multiline < Cop
        MSG = "Put each statement of a `%<name>s` body on its own line"

        private

          # xs.each do |k| p(k) end
          # xs.each do |k|
          #   p(k)
          # end
          # ---
          def rule(node)
            case node
            in SyntaxTree::Program | SyntaxTree::BodyStmt
              nil

            in { bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[ body: body ] ] }
              crowded(node, body)

            in { statements: SyntaxTree::Statements[ body: body ] }
              crowded(node, body)

            else
              nil
            end
          end

          def crowded(node, body)
            statements = body.reject { |statement| statement.is_a?(SyntaxTree::VoidStmt) }
            return if statements.empty?
            return unless statements.any? { |statement| statement.location.start_line == node.location.start_line }

            add_offense(range(node.location), message: format(MSG, name: keyword(node))) do |corrector|
              statements.each do |statement|
                next unless statement.location.start_line == node.location.start_line

                corrector.replace(
                  before(statement.location),
                  "\n#{" " * (indentation(node.location) + Indentation::WIDTH)}"
                )
              end

              if closes_own_line?(node, statements.last)
                corrector.replace(
                  gap(statements.last.location),
                  "\n#{" " * indentation(node.location)}"
                )
              end
            end
          end

          def indentation(location)
            raw = processed_source.raw_source
            opening = raw.rindex("\n", location.start_char - 1).then { |index| index ? index + 1 : 0 }

            raw[opening..].match(/\A[ \t]*/)[0].length
          end

          # The run of spaces a statement was crowded onto its opener's line by.
          def before(location)
            raw = processed_source.raw_source
            opening = location.start_char
            opening -= 1 while raw[opening - 1] == " " || raw[opening - 1] == "\t"

            Parser::Source::Range.new(processed_source.buffer, opening, location.start_char)
          end

          # The run of spaces between a body and the closer that follows it.
          def gap(location)
            raw = processed_source.raw_source
            closing = location.end_char
            closing += 1 while raw[closing] == " " || raw[closing] == "\t"

            Parser::Source::Range.new(processed_source.buffer, location.end_char, closing)
          end

          # A clause has no closer of its own; everything else ends with `end`,
          # which belongs on its own line.
          def closes_own_line?(node, last)
            case node
            in SyntaxTree::When | SyntaxTree::Else | SyntaxTree::In
              false

            else
              node.location.end_line == last.location.end_line
            end
          end

          def keyword(node)
            node.class.name.split("::").last.sub(/Node\z/, "").downcase
          end
      end
    end
  end
end
