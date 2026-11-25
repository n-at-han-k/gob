# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Assignments
        module_function

        def register(matcher)
          matcher.rule(:package_map_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Assign)

            node => SyntaxTree::Assign[
              target: SyntaxTree::VarField[
                value: SyntaxTree::Ident[value: name]
              ],
              value: SyntaxTree::HashLiteral[assocs: assocs]
            ]

            next Matcher::MISS unless package_scope?

            MapAssignment(name, assocs, context: self)
          end

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

          matcher.rule(:field_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Assign)

            node => SyntaxTree::Assign[
              target: SyntaxTree::Field[
                parent: parent,
                operator: SyntaxTree::Period[value: "."],
                name: SyntaxTree::Const[value: name]
              ],
              value: value
            ]

            AssignStmt([SelectorExpr(visit(parent), name)], "=", [visit(value)])
          end

          matcher.rule(:index_field_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Assign)

            node => SyntaxTree::Assign[
              target: SyntaxTree::ARefField[
                collection: collection, index: SyntaxTree::Args[parts: [index]]
              ],
              value: value
            ]

            AssignStmt(
              [IndexExpr(visit(collection), visit(index))],
              "=",
              [visit(value)]
            )
          end

          matcher.rule(:index_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Assign)

            node => SyntaxTree::Assign[
              target: SyntaxTree::ARef[
                collection: collection, index: SyntaxTree::Args[parts: [index]]
              ],
              value: value
            ]

            AssignStmt(
              [IndexExpr(visit(collection), visit(index))],
              "=",
              [visit(value)]
            )
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
