# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Switches
        module_function

        def register(matcher)
          matcher.rule(:type_switch) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Case)

            node => SyntaxTree::Case[
              value: SyntaxTree::Assign[
                target: SyntaxTree::VarField[
                  value: SyntaxTree::Ident[value: name]
                ],
                value: SyntaxTree::CallNode[
                  receiver: receiver,
                  operator: SyntaxTree::Period[value: "."],
                  message: :call,
                  arguments: SyntaxTree::ArgParen[
                    arguments: SyntaxTree::Args[
                      parts: [
                        SyntaxTree::VCall[
                          value: SyntaxTree::Ident[value: "type"]
                        ]
                      ]
                    ]
                  ]
                ]
              ],
              consequent: consequent
            ]

            TypeSwitch(name, receiver, consequent, context: self)
          end

          matcher.rule(:case_expression) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Case)

            node => SyntaxTree::Case[value: value, consequent: consequent]

            CaseExpression(value, consequent, context: self)
          end

          matcher.rule(:when_clause) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::When)

            node => SyntaxTree::When[
              arguments: SyntaxTree::Args[parts: arguments],
              statements: SyntaxTree::Statements[body: body]
            ]

            WhenClause(arguments, body, context: self)
          end

          matcher.rule(:else_clause) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Else)

            node => SyntaxTree::Else[
              statements: SyntaxTree::Statements[body: body]
            ]

            CaseClause(
              [],
              visit_all(body).map { |statement| stmtify(statement) }
            )
          end
        end
      end
    end
  end
end
