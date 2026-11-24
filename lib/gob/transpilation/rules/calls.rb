# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Calls
        module_function

        def register(matcher)
          matcher.rule(:drop_struct_new) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: SyntaxTree::VarRef[
                value: SyntaxTree::Const[value: "Struct"]
              ],
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "new"]
            ]

            Matcher::DROP
          end

          matcher.rule(:drop_struct_instance) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: SyntaxTree::CallNode[
                receiver: SyntaxTree::VarRef[
                  value: SyntaxTree::Const[value: "Struct"]
                ],
                operator: SyntaxTree::Period[value: "."],
                message: SyntaxTree::Ident[value: "new"]
              ],
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "new"]
            ]

            Matcher::DROP
          end

          matcher.rule(:constructor) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "new"],
              arguments: arguments
            ]

            StructLiteral(receiver, arguments, context: self)
          end

          matcher.rule(:type_assertion) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: :call,
              arguments: SyntaxTree::ArgParen[
                arguments: SyntaxTree::Args[
                  parts: [
                    SyntaxTree::VCall[value: SyntaxTree::Ident[value: "type"]]
                  ]
                ]
              ]
            ]

            TypeAssertExpr(visit(receiver))
          end

          matcher.rule(:lambda_call) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: SyntaxTree::MethodAddBlock,
              operator: SyntaxTree::Period[value: "."],
              message: :call,
              arguments: arguments
            ]

            CallExpr(visit(node.receiver), visit_args(arguments))
          end

          matcher.rule(:conversion_assertion) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: :call,
              arguments: SyntaxTree::ArgParen[
                arguments: SyntaxTree::Args[parts: [type]]
              ]
            ]

            TypeAssertExpr(visit(receiver), GoType(type, context: self))
          end

          matcher.rule(:pointer_property) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: SyntaxTree::VarRef[
                value: SyntaxTree::IVar[value: receiver_name]
              ],
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Const[value: name],
              arguments: nil
            ]

            UnaryExpr(
              :&,
              SelectorExpr(Ident(receiver_name.delete_prefix("@")), name)
            )
          end

          matcher.rule(:selector_property) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Const[value: name],
              arguments: nil
            ]

            SelectorExpr(visit(receiver), name)
          end

          matcher.rule(:selector_property_ident) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: name],
              arguments: nil
            ]

            SelectorExpr(visit(receiver), name)
          end

          matcher.rule(:selector_call) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Const[value: name],
              arguments: arguments
            ]

            CallExpr(SelectorExpr(visit(receiver), name), visit_args(arguments))
          end

          matcher.rule(:make_call) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: "make"],
              arguments: arguments
            ]

            CallExpr(Ident("make"), visit_args(arguments))
          end

          matcher.rule(:function_call) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

            node => SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: name],
              arguments: arguments
            ]

            CallExpr(Ident(name), visit_args(arguments))
          end

          matcher.rule(:command_call) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CommandCall)

            node => SyntaxTree::CommandCall[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: name],
              arguments: SyntaxTree::Args[parts: parts]
            ]

            CallExpr(SelectorExpr(visit(receiver), name), visit_all(parts))
          end

          matcher.rule(:safe_navigation) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::CallNode)

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
