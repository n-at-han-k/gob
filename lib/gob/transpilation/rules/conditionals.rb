# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Conditionals
        module_function

        def register(matcher)
          matcher.rule(:if_error_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::IfNode)

            node => SyntaxTree::IfNode[
              predicate: SyntaxTree::Assign[
                target: SyntaxTree::VarField[
                  value: SyntaxTree::Ident[value: "err"]
                ],
                value: value
              ],
              statements: SyntaxTree::Statements[body: body],
              consequent: consequent
            ]

            IfErrorAssignment(["err"], value, body, consequent, context: self)
          end

          matcher.rule(:if_error_assignment_tail) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::IfNode)

            node => SyntaxTree::IfNode[
              predicate: SyntaxTree::Paren[
                contents: SyntaxTree::Statements[
                  body: [
                    SyntaxTree::MAssign[
                      target: SyntaxTree::MLHS[parts: targets], value: value
                    ]
                  ]
                ]
              ],
              statements: SyntaxTree::Statements[body: body],
              consequent: consequent
            ]

            targets => [
              *,
              SyntaxTree::VarField[value: SyntaxTree::Ident[value: "err"]]
            ]

            IfErrorAssignment(
              AssignmentNames(targets),
              value,
              body,
              consequent,
              context: self
            )
          end

          matcher.rule(:if_error_assignment_head) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::IfNode)

            node => SyntaxTree::IfNode[
              predicate: SyntaxTree::Paren[
                contents: SyntaxTree::Statements[
                  body: [
                    SyntaxTree::MAssign[
                      target: SyntaxTree::MLHS[parts: targets], value: value
                    ]
                  ]
                ]
              ],
              statements: SyntaxTree::Statements[body: body],
              consequent: consequent
            ]

            targets => [
              SyntaxTree::VarField[value: SyntaxTree::Ident[value: "err"]],
              *
            ]

            IfErrorAssignment(
              AssignmentNames(targets),
              value,
              body,
              consequent,
              context: self
            )
          end

          matcher.rule(:if_boolean_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::IfNode)

            node => SyntaxTree::IfNode[
              predicate: SyntaxTree::Paren[
                contents: SyntaxTree::Statements[
                  body: [
                    SyntaxTree::MAssign[
                      target: SyntaxTree::MLHS[
                        parts: [
                          SyntaxTree::VarField[
                            value: SyntaxTree::Ident[value: value_name]
                          ],
                          SyntaxTree::VarField[
                            value: SyntaxTree::Ident[value: "ok"]
                          ]
                        ]
                      ],
                      value: value
                    ]
                  ]
                ]
              ],
              statements: SyntaxTree::Statements[body: body],
              consequent: consequent
            ]

            IfBooleanAssignment(
              [value_name, "ok"],
              "ok",
              value,
              body,
              consequent,
              context: self
            )
          end

          matcher.rule(:if_condition) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::IfNode)

            node => SyntaxTree::IfNode[
              predicate: predicate,
              statements: SyntaxTree::Statements[body: body],
              consequent: nil
            ]

            IfCondition(predicate, body, nil, context: self)
          end

          matcher.rule(:if_else) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::IfNode)

            node => SyntaxTree::IfNode[
              predicate: predicate,
              statements: SyntaxTree::Statements[body: body],
              consequent: SyntaxTree::Else[
                statements: SyntaxTree::Statements[body: _else_body]
              ]
            ]

            IfCondition(predicate, body, node.consequent, context: self)
          end

          matcher.rule(:elsif) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Elsif)

            node => SyntaxTree::Elsif[
              predicate: predicate,
              statements: SyntaxTree::Statements[body: body],
              consequent: consequent
            ]

            IfCondition(predicate, body, consequent, context: self)
          end

          matcher.rule(:unless) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::UnlessNode)

            node => SyntaxTree::UnlessNode[
              predicate: predicate,
              statements: SyntaxTree::Statements[body: body],
              consequent: consequent
            ]

            UnlessCondition(predicate, body, consequent, context: self)
          end
        end
      end
    end
  end
end
