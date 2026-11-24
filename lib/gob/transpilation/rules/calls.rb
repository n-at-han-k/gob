# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Calls
        module_function

        def register(matcher)
          matcher.rule(:constructor) do |node|
            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "new"],
              arguments: arguments
            ]

            StructLiteral(receiver, arguments, context: self)
          end

          matcher.rule(:selector_property) do |node|
            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Const[value: name],
              arguments: nil
            ]

            SelectorExpr(visit(receiver), name)
          end

          matcher.rule(:selector_call) do |node|
            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Const[value: name],
              arguments: arguments
            ]

            CallExpr(SelectorExpr(visit(receiver), name), visit_args(arguments))
          end

          matcher.rule(:make_call) do |node|
            node => SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: "make"],
              arguments: arguments
            ]

            CallExpr(Ident("make"), visit_args(arguments))
          end

          matcher.rule(:function_call) do |node|
            node => SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: name],
              arguments: arguments
            ]

            CallExpr(Ident(name), visit_args(arguments))
          end

          matcher.rule(:command_call) do |node|
            node => SyntaxTree::CommandCall[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: name],
              arguments: SyntaxTree::Args[parts: parts]
            ]

            CallExpr(SelectorExpr(visit(receiver), name), visit_all(parts))
          end

          matcher.rule(:safe_navigation) do |node|
            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Op[value: "&."],
              message: SyntaxTree::Ident[value: name],
              arguments: nil
            ]

            SelectorExpr(visit(receiver), name)
          end
        end
      end
    end
  end
end
