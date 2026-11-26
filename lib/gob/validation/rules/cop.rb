# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class Cop < RuboCop::Cop::Base
        exclude_from_registry
        extend RuboCop::Cop::AutoCorrector

        def self.badge
          @badge ||= RuboCop::Cop::Badge.parse("Gob/#{name.split("::").last}")
        end

        # A rule matches the source the same way the transpiler does, so that
        # what is legal here is exactly what the transpiler knows how to read.
        def on_new_investigation
          walk(SyntaxTree.parse(processed_source.raw_source))
        rescue SyntaxTree::Parser::ParseError
          nil
        end

        private

          def walk(node)
            case node
            in Array
              node.each { |child| walk(child) }

            in SyntaxTree::Node
              @ancestors ||= []
              @ancestors << node
              rule(node)
              walk(node.child_nodes)
              @ancestors.pop

            else
              nil
            end
          end

          def body_statements(bodystmt)
            case bodystmt
            in SyntaxTree::BodyStmt[statements: SyntaxTree::Statements[body: body]]
              body
            in SyntaxTree::Statements[body: body]
              body
            else
              []
            end
          end

          def rule(node)
            nil
          end

          def source(location)
            processed_source.raw_source[location.start_char...location.end_char]
          end

          def range(location)
            Parser::Source::Range.new(
              processed_source.buffer,
              location.start_char,
              location.end_char
            )
          end

          # The whole line a node sits on, newline included.
          def line(location)
            raw = processed_source.raw_source
            opening = raw.rindex("\n", location.start_char - 1).then { |index| index ? index + 1 : 0 }
            closing = raw.index("\n", location.end_char).then { |index| index ? index + 1 : raw.length }

            Parser::Source::Range.new(processed_source.buffer, opening, closing)
          end

          # The position just before the newline that ends a node's first line.
          def end_of_line(location)
            raw = processed_source.raw_source
            closing = raw.index("\n", location.start_char) || raw.length

            Parser::Source::Range.new(processed_source.buffer, closing, closing)
          end
      end
    end
  end
end
