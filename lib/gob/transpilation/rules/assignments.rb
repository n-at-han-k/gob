# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Assignments
        module_function

        def register(matcher)
          matcher.rule(:package_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Assign)

            node => SyntaxTree::Assign[
              target: SyntaxTree::VarField[
                value: SyntaxTree::Ident[value: name]
              ],
              value: value
            ]

            next Matcher::MISS unless package_scope?

            GenDecl(:var, [ValueSpec([name], values: [visit(value)])])
          end

          matcher.rule(:local_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Assign)

            node => SyntaxTree::Assign[
              target: SyntaxTree::VarField[
                value: SyntaxTree::Ident[value: name]
              ],
              value: value
            ]

            next Matcher::MISS if package_scope?

            LocalAssignment([name], [visit(value)], context: self)
          end

          matcher.rule(:multiple_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::MAssign)

            node => SyntaxTree::MAssign[
              target: SyntaxTree::MLHS[parts: targets], value: value
            ]

            names =
              targets.map do |target|
                case target
                in SyntaxTree::VarField[value: SyntaxTree::Ident[value: name]]
                  name
                end
              end
            values =
              case value
              in SyntaxTree::MRHS[parts: parts]
                visit_all(parts)
              else
                [visit(value)]
              end

            LocalAssignment(names, values, context: self)
          end

          matcher.rule(:receiver_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Assign)

            node => SyntaxTree::Assign[
              target: SyntaxTree::VarField[
                value: SyntaxTree::CVar[value: name]
              ],
              value: value
            ]

            AssignStmt(
              [StarExpr(Ident(name.delete_prefix("@@")))],
              "=",
              [visit(value)]
            )
          end
        end
      end
    end
  end
end
