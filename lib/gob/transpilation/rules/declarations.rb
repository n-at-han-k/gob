# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Declarations
        module_function

        def register(matcher)
          matcher.rule(:require) do |node|
            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "require"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::StringLiteral[
                    parts: [SyntaxTree::TStringContent[value: path]]
                  ]
                ]
              ]
            ]

            GenDecl(:import, [ImportSpec(path)])
          end

          matcher.rule(:var_declaration) do |node|
            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::SymbolLiteral[
                    value: SyntaxTree::Ident[value: name]
                  ],
                  type
                ]
              ]
            ]

            GenDecl(:var, [ValueSpec([name], GoType(type, context: self))])
          end

          matcher.rule(:var_declaration_with_value) do |node|
            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::SymbolLiteral[
                    value: SyntaxTree::Ident[value: name]
                  ],
                  type,
                  value
                ]
              ]
            ]

            GenDecl(
              :var,
              [
                ValueSpec(
                  [name],
                  GoType(type, context: self),
                  values: [visit(value)]
                )
              ]
            )
          end

          matcher.rule(:const_declaration) do |node|
            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "const"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::SymbolLiteral[
                    value: SyntaxTree::Ident[value: name]
                  ],
                  value
                ]
              ]
            ]

            GenDecl(:const, [ValueSpec([name], values: [visit(value)])])
          end

          matcher.rule(:package_constant) do |node|
            node => SyntaxTree::Assign[
              target: SyntaxTree::VarField[
                value: SyntaxTree::Const[value: name]
              ],
              value: value
            ]
            next Matcher::MISS unless package_scope?

            GenDecl(
              :const,
              [
                ValueSpec(
                  [Gob::Transpilation::Rules.const_go_name(name)],
                  values: [visit(value)]
                )
              ]
            )
          end

          matcher.rule(:struct_definition) do |node|
            node => SyntaxTree::ClassDeclaration[
              constant: SyntaxTree::ConstRef[
                constant: SyntaxTree::Const[value: name]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]

            StructDefinition(name, body, context: self)
          end

          matcher.rule(:struct_new) do |node|
            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::Assign[
                    target: SyntaxTree::VarField[
                      value: SyntaxTree::Ident[value: name]
                    ],
                    value: SyntaxTree::CallNode[
                      receiver: SyntaxTree::VarRef[
                        value: SyntaxTree::Const[value: "Struct"]
                      ],
                      operator: SyntaxTree::Period[value: "."],
                      message: SyntaxTree::Ident[value: "new"],
                      arguments: SyntaxTree::ArgParen[
                        arguments: SyntaxTree::Args[parts: arguments]
                      ]
                    ]
                  ]
                ]
              ]
            ]

            case arguments.first
            in SyntaxTree::BareAssocHash[assocs: assocs]
              StructNew(name, assocs, context: self)
            in SyntaxTree::SymbolLiteral[
              value: SyntaxTree::Const[value: field_name]
            ]
              StructNewFromNames(name, [field_name])
            else
              names =
                arguments.filter_map do |argument|
                  case argument
                  in SyntaxTree::SymbolLiteral[
                    value: SyntaxTree::Const[value: field_name]
                  ]
                    field_name
                  end
                end
              StructNewFromNames(name, names)
            end
          end
        end
      end
    end
  end
end
