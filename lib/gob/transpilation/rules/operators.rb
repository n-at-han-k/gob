# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Operators
        module_function

        def register(matcher)
          matcher.rule(:boolean_and_or) do |node|
            node => SyntaxTree::Binary[
              left: left, operator: operator, right: right
            ]

            next Matcher::MISS unless %w[and or && ||].include?(operator.to_s)

            BinaryExpr(visit(left), operator, visit(right))
          end

          matcher.rule(:binary) do |node|
            node => SyntaxTree::Binary[
              left: left, operator: operator, right: right
            ]

            BinaryExpr(visit(left), operator, visit(right))
          end

          matcher.rule(:unary) do |node|
            node => SyntaxTree::Unary[operator: operator, statement: statement]

            UnaryExpr(operator, visit(statement))
          end

          matcher.rule(:not_operator) do |node|
            node => SyntaxTree::Not[statement: statement]

            UnaryExpr(:!, visit(statement))
          end

          matcher.rule(:op_assign) do |node|
            node => SyntaxTree::OpAssign[
              target: SyntaxTree::VarField[
                value: SyntaxTree::Ident[value: name]
              ],
              operator: SyntaxTree::Op[value: operator],
              value: value
            ]

            AssignStmt([Ident(name)], operator, [visit(value)])
          end
        end
      end
    end
  end
end
