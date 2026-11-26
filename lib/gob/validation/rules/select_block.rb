# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Uses Gob's case/when spelling for a select that receives from channels.
      class SelectBlock < Cop
        MSG = "Write channel receives as `case` / `when` clauses"

        private

          # select do |c|
          #   c << ready() { return value }
          # end
          # ---
          # case
          # when ~ready()
          #   return value
          # end
          # ---
          def rule(node)
            case node
            in SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: nil,
                operator: nil,
                message: SyntaxTree::Ident[value: "select"]
              ],
              block: SyntaxTree::BlockNode[
                block_var: SyntaxTree::BlockVar[
                  params: SyntaxTree::Params[requireds: [channel]]
                ],
                bodystmt: bodystmt
              ]
            ] if !body_statements(bodystmt).empty? && body_statements(bodystmt).all? { |statement| send_with_block?(statement, channel) }
              add_offense(range(node.location), message: MSG) do |corrector|
                corrector.replace(range(node.location), replacement(node, body_statements(bodystmt)))
              end

            else
              nil
            end
          end

          def send_with_block?(node, channel)
            case node
            in SyntaxTree::Binary[
              left: SyntaxTree::VarRef[value: SyntaxTree::Ident[value: name]],
              operator: :<<,
              right: SyntaxTree::MethodAddBlock[
                call: call,
                block: SyntaxTree::BlockNode[bodystmt: bodystmt]
              ]
            ] if name == channel.value && !body_statements(bodystmt).empty?
              true
            else
              false
            end
          end

          def replacement(node, body)
            indent = indentation(node.location)
            clauses = body.map do |statement|
              call = statement.right.call
              statements = body_statements(statement.right.block.bodystmt)
              clause_body = statements.map { |item| source(item.location) }.join("\n")
              "#{" " * indent}when ~#{source(call.location)}\n#{indent_source(clause_body, indent + 2)}"
            end

            "#{" " * indent}case\n#{clauses.join("\n")}\n#{" " * indent}end"
          end

          def indent_source(source_text, depth)
            source_text.lines.map { |line| "#{" " * depth}#{line.lstrip}" }.join.rstrip
          end

          def indentation(location)
            raw = processed_source.raw_source
            opening = raw.rindex("\n", location.start_char - 1).then { |index| index ? index + 1 : 0 }
            raw[opening..].match(/\A[ \t]*/)[0].length
          end
      end
    end
  end
end
