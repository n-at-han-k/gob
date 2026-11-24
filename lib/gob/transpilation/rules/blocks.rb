# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Blocks
        module_function

        def register(matcher)
          matcher.rule(:begin_block) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Begin)

            node => SyntaxTree::Begin[
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]

            BlockStmt(
              scoped { visit_all(body).map { |statement| stmtify(statement) } }
            )
          end

          matcher.rule(:assoc) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Assoc)

            node => SyntaxTree::Assoc[key: key, value: value]

            KeyValueExpr(visit(key), visit(value))
          end

          matcher.rule(:bare_assoc_hash) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::BareAssocHash)

            node => SyntaxTree::BareAssocHash[assocs: assocs]

            HashLiteral(visit_all(assocs))
          end

          matcher.rule(:hash_literal) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::HashLiteral)

            node => SyntaxTree::HashLiteral[assocs: assocs]

            HashLiteral(visit_all(assocs))
          end

          matcher.rule(:array_literal) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::ArrayLiteral)

            node => SyntaxTree::ArrayLiteral[contents: contents]

            elements =
              case contents
              in SyntaxTree::Args[parts: parts]
                parts
              else
                Array(contents)
              end

            ArrayLiteral(visit_all(elements))
          end

          matcher.rule(:block_arguments) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::ArgBlock)

            node => SyntaxTree::ArgBlock[value: value]

            visit(value)
          end
        end
      end
    end
  end
end
