# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Literals
        module_function

        def register(matcher)
          matcher.rule(:empty_string) do |node|
            node => SyntaxTree::StringLiteral[parts: []]

            StringLiteral("")
          end

          matcher.rule(:string_literal) do |node|
            node => SyntaxTree::StringLiteral[
              parts: [SyntaxTree::TStringContent[value: value]]
            ]

            StringLiteral(value)
          end

          matcher.rule(:raw_string_literal) do |node|
            node => SyntaxTree::XStringLiteral[
              parts: [SyntaxTree::TStringContent[value: value]]
            ]

            RawStringLiteral(value)
          end

          matcher.rule(:string_concat) do |node|
            node => SyntaxTree::StringConcat[left: left, right: right]

            BinaryExpr(visit(left), :+, visit(right))
          end

          matcher.rule(:integer_literal) do |node|
            node => SyntaxTree::Int[value: value]

            IntLiteral(value)
          end

          matcher.rule(:float_literal) do |node|
            node => SyntaxTree::FloatLiteral[value: value]

            FloatLiteral(value)
          end

          matcher.rule(:keyword_literal) do |node|
            node => SyntaxTree::VarRef[value: SyntaxTree::Kw[value: value]]

            next Matcher::MISS unless %w[true false nil].include?(value)

            Ident(value)
          end

          matcher.rule(:symbol_literal) do |node|
            node => SyntaxTree::SymbolLiteral[value: value]

            name =
              case value
              in SyntaxTree::Ident[value: identifier]
                identifier
              in SyntaxTree::Const[value: constant]
                constant
              end

            Ident(name)
          end

          matcher.rule(:dynamic_symbol) do |node|
            node => SyntaxTree::DynaSymbol[
              parts: [SyntaxTree::TStringContent[value: value]]
            ]

            Ident(value)
          end
        end
      end
    end
  end
end
