# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Functions
        module_function

        def register(matcher)
          matcher.rule(:method) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::DefNode)

            node => SyntaxTree::DefNode[
              target: nil,
              operator: nil,
              name: SyntaxTree::Const[value: _name],
              params: SyntaxTree::Paren[
                contents: SyntaxTree::Params[requireds: _parameters],
                comments: [SyntaxTree::Comment[value: /^#\s*\(/ => signature]]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]

            Method(node.name, node.params, signature, body, context: self)
          end

          matcher.rule(:signed_function) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::DefNode)

            node => SyntaxTree::DefNode[
              target: nil,
              operator: nil,
              name: SyntaxTree::Ident[value: _name],
              params: SyntaxTree::Paren[
                contents: SyntaxTree::Params[requireds: _parameters],
                comments: [SyntaxTree::Comment[value: /^#\s*\(/ => signature]]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]

            SignedFunction(
              node.name,
              node.params,
              signature,
              body,
              context: self
            )
          end

          matcher.rule(:method_returns_only) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::DefNode)

            node => SyntaxTree::DefNode[
              target: nil,
              operator: nil,
              name: SyntaxTree::Const[value: _name],
              params: SyntaxTree::Params[
                comments: [SyntaxTree::Comment[value: /^#\s*->/ => signature]]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]

            MethodReturnsOnly(node.name, signature, body, context: self)
          end

          matcher.rule(:returns_only_function) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::DefNode)

            node => SyntaxTree::DefNode[
              target: nil,
              operator: nil,
              name: SyntaxTree::Ident[value: _name],
              params: SyntaxTree::Params[
                comments: [SyntaxTree::Comment[value: /^#\s*->/ => signature]]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]

            ReturnsOnlyFunction(node.name, signature, body, context: self)
          end

          matcher.rule(:function) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::DefNode)

            node => SyntaxTree::DefNode[
              target: nil,
              operator: nil,
              name: SyntaxTree::Ident[value: _name],
              params: params,
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]

            UnsignedFunction(node.name, params, body, context: self)
          end

          matcher.rule(:lambda) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::MethodAddBlock)

            node => SyntaxTree::MethodAddBlock[
              call: SyntaxTree::CallNode[
                receiver: nil,
                operator: nil,
                message: SyntaxTree::Ident[value: "lambda"]
              ],
              block: SyntaxTree::BlockNode[
                block_var: block_var, bodystmt: bodystmt
              ]
            ]

            Lambda(block_var, BodyStatements(bodystmt), context: self)
          end
        end
      end
    end
  end
end
