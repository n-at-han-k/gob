# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Program
        module_function

        def register(matcher)
          matcher.rule(:program) do |node|
            node => SyntaxTree::Program[
              statements: SyntaxTree::Statements[body: body]
            ]

            PackageFile("main", visit_all(body))
          end

          matcher.rule(:main_module) do |node|
            node => SyntaxTree::ModuleDeclaration[
              constant: SyntaxTree::ConstRef[
                constant: SyntaxTree::Const[value: "Main"]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]

            visit_all(body)
          end
        end
      end
    end
  end
end
