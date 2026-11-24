# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module Declarations
        module_function

        def register(matcher)
          matcher.rule(:require) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

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

          matcher.rule(:var_inferred_type) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var" | "define_var"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::Command[
                    message: SyntaxTree::Ident[value: name],
                    arguments: SyntaxTree::Args[parts: [type]]
                  ]
                ]
              ]
            ]

            VarDeclaration(name, GoType(type, context: self), [], context: self)
          end

          matcher.rule(:var_declaration) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var" | "define_var"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::SymbolLiteral[
                    value: SyntaxTree::Ident[value: name]
                  ],
                  type
                ]
              ]
            ]

            VarDeclaration(name, GoType(type, context: self), [], context: self)
          end

          matcher.rule(:var_declaration_with_value) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var" | "define_var"],
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

            VarDeclaration(
              name,
              GoType(type, context: self),
              [visit(value)],
              context: self
            )
          end

          matcher.rule(:const_declaration) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "const" | "define_const"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::SymbolLiteral[
                    value: SyntaxTree::Ident[value: name]
                  ],
                  value
                ]
              ]
            ]

            ConstDeclaration(name, visit(value), context: self)
          end

          matcher.rule(:package_constant) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Assign)

            node => SyntaxTree::Assign[
              target: SyntaxTree::VarField[
                value: SyntaxTree::Const[value: name]
              ],
              value: value
            ]

            next Matcher::MISS unless package_scope?

            ConstDeclaration(
              Gob::Transpilation::Rules.const_go_name(name),
              visit(value),
              context: self
            )
          end

          matcher.rule(:struct_definition) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::ClassDeclaration)

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

          matcher.rule(:struct_new_with_block) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var" | "define_var"],
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
                        arguments: SyntaxTree::Args[
                          parts: arguments, comments: comments
                        ]
                      ]
                    ]
                  ]
                ]
              ],
              block: SyntaxTree::BlockNode[
                bodystmt: SyntaxTree::BodyStmt[
                  statements: SyntaxTree::Statements[body: body]
                ]
              ]
            ]

            StructNewWithBlock(
              name,
              arguments,
              body,
              comments: comments,
              context: self
            )
          end

          matcher.rule(:struct_new) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var" | "define_var"],
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
                        arguments: SyntaxTree::Args[
                          parts: arguments, comments: comments
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]

            case arguments.first
            in SyntaxTree::BareAssocHash[assocs: assocs]
              StructNew(name, assocs, comments: comments, context: self)
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

          matcher.rule(:var_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var" | "define_var"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::Assign[
                    target: SyntaxTree::VarField[
                      value: SyntaxTree::Ident[value: name]
                    ],
                    value: value
                  ]
                ]
              ]
            ]

            VarDeclaration(name, nil, [visit(value)], context: self)
          end

          matcher.rule(:const_assignment) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "const" | "define_const"],
              arguments: SyntaxTree::Args[
                parts: [
                  SyntaxTree::Assign[
                    target: SyntaxTree::VarField[
                      value: SyntaxTree::Ident[value: name]
                    ],
                    value: value
                  ]
                ]
              ]
            ]

            ConstDeclaration(name, visit(value), context: self)
          end

          matcher.rule(:attr_accessor) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "attr_accessor"]
            ]

            Matcher::DROP
          end

          matcher.rule(:command) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::Command)

            node => SyntaxTree::Command[
              message: SyntaxTree::Ident[value: name],
              arguments: SyntaxTree::Args[parts: parts]
            ]

            if %w[var const define_var define_const].include?(name)
              next Matcher::MISS
            end

            CallExpr(Ident(name), visit_all(parts))
          end
        end
      end
    end
  end
end
