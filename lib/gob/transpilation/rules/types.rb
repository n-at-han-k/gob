# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Types
        module_function

        def register(matcher)
          matcher.rule(:named_type) do |node|
            case node
            in SyntaxTree::VCall[value: SyntaxTree::Ident[value: name]]
              Ident(name)
            in SyntaxTree::VarRef[value: SyntaxTree::Const[value: name]]
              Ident(name)
            in SyntaxTree::SymbolLiteral[value: SyntaxTree::Ident[value: name]]
              Ident(name)
            else
              Matcher::MISS
            end
          end

          matcher.rule(:pointer_type) do |node|
            case node
            in SyntaxTree::IVar[value: name]
              StarExpr(Ident(name.delete_prefix("@")))
            in SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: "ptr" | "ref"],
              arguments: SyntaxTree::ArgParen[
                arguments: SyntaxTree::Args[parts: [type]]
              ]
            ]
              StarExpr(GoType(type, context: self))
            else
              Matcher::MISS
            end
          end

          matcher.rule(:proc_type) do |node|
            node => SyntaxTree::ARef[
              collection: SyntaxTree::VarRef[
                value: SyntaxTree::Const[value: "Proc"]
              ],
              index: SyntaxTree::Args[parts: parameters]
            ]

            ProcType(parameters, nil, context: self)
          end

          matcher.rule(:array_type) do |node|
            node => SyntaxTree::ARef[
              collection: SyntaxTree::VarRef[
                value: SyntaxTree::Const[value: "Array"]
              ],
              index: SyntaxTree::Args[parts: [element]]
            ]

            ArrayType(GoType(element, context: self))
          end

          matcher.rule(:fixed_array_type) do |node|
            node => SyntaxTree::ARef[
              collection: SyntaxTree::VarRef[
                value: SyntaxTree::Const[value: "Array"]
              ],
              index: SyntaxTree::Args[parts: [element, length]]
            ]

            ArrayType(GoType(element, context: self), visit(length))
          end

          matcher.rule(:hash_type) do |node|
            node => SyntaxTree::ARef[
              collection: SyntaxTree::VarRef[
                value: SyntaxTree::Const[value: "Hash" | "Map"]
              ],
              index: SyntaxTree::Args[parts: [key, value]]
            ]

            MapType(GoType(key, context: self), GoType(value, context: self))
          end
        end
      end
    end
  end
end
