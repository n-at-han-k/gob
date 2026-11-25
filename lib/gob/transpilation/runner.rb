#!/usr/bin/env ruby
#
# runner.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#

module Gob
  module Transpilation
    class Runner
      module PackageNodes
        def Package(name:, declarations:)
          SyntaxTree::Go::File.new(
            name: SyntaxTree::Go::Ident.new(name: name.to_s),
            decls: declarations
          )
        end
      end

      module FunctionNodes
        def parse_signature_comment(text)
          case text.split(/\s*->\s*/, 2)
          in [/\A#\s*\z/, ret] unless ret.empty?
            { params: [], returns: ret.delete_prefix("(").delete_suffix(")").split(/\s*,\s*/) }
          in [/\A#\s*\(([^)]*)\)\z/, ret] unless ret.empty?
            { params: $1.split(/\s*,\s*/), returns: ret.delete_prefix("(").delete_suffix(")").split(/\s*,\s*/) }
          in [/\A#\s*(.+)\z/, ret] unless ret.empty?
            { params: $1.split(/\s*,\s*/), returns: ret.delete_prefix("(").delete_suffix(")").split(/\s*,\s*/) }
          in [/\A#\s*\(([^)]*)\)\s*\z/]
            { params: $1.split(/\s*,\s*/), returns: [] }
          else
            { params: [], returns: [] }
          end
        end

        def Function(name:, params:, body:)
          case params
          in { contents: SyntaxTree::Params[requireds: args], comments: [SyntaxTree::Comment[value: types], *] }
            input, output = parse_signature_comment(types).values_at(:params, :returns)
            params = args.map { |arg|
              SyntaxTree::Go::Field.new(
                names: [ SyntaxTree::Go::Ident.new(name: arg.value) ],
                type: SyntaxTree::Go::Ident.new(name: input.shift)
              )
            }
            results = output.map { |result|
              SyntaxTree::Go::Field.new(
                names: [ SyntaxTree::Go::Ident.new(name: result.value) ],
              )
            }

          in { contents: SyntaxTree::Params[requireds: args] }
            params = args.map { |arg|
              SyntaxTree::Go::Field.new(
                names: [ SyntaxTree::Go::Ident.new(name: arg.value) ],
                type: SyntaxTree::Go::Ident.new(name: input.shift)
              )
            }
            results = []

          in { comments: [SyntaxTree::Comment[value: types], *] }
            _, output = parse_signature_comment(types).values_at(:params, :returns)
            params = []
            results = output.map { |result|
              SyntaxTree::Go::Field.new(
                names: [ SyntaxTree::Go::Ident.new(name: result.value) ],
              )
            }

          else
            params = []
            results = []

          end

          SyntaxTree::Go::FuncDecl.new(
            name: SyntaxTree::Go::Ident.new(name: name),
            type: SyntaxTree::Go::FuncType.new(
              type_params: nil,
              params: SyntaxTree::Go::FieldList.new(list: params),
              results: SyntaxTree::Go::FieldList.new(list: results),
            ),
            body: SyntaxTree::Go::BlockStmt.new(list: body)
          )
        end
      end

      module BlockNodes
        def Block(body:)
          SyntaxTree::Go::BlockStmt.new(list: body)
        end
      end

      module LogicNodes
        def Logic(node)
          nil
        end
      end

      module CommentNodes
        def Comment(value:)
          SyntaxTree::Go::Comment.new(text: value)
        end
      end

      module VariableNodes
        def Variable(node)
          case node
          in SyntaxTree::CVar[value: name]
            SyntaxTree::Go::StarExpr.new(
              x: SyntaxTree::Go::Ident.new(name: name.delete_prefix("@@"))
            )

          in { value: name }
            SyntaxTree::Go::Ident.new(name: name)
          end
        end

        def Ident(name)
          SyntaxTree::Go::Ident.new(name: name.to_s)
        end

        def BasicLit(kind, value)
          SyntaxTree::Go::BasicLit.new(kind: kind.to_sym, value: value.to_s)
        end

        def CharLiteral(value)
          BasicLit(:CHAR, "'#{value}'")
        end

        def StringLiteral(value)
          BasicLit(:STRING, "\"#{value}\"")
        end

        def RawStringLiteral(value)
          BasicLit(:STRING, "`#{value}`")
        end

        def IntLiteral(value)
          BasicLit(:INT, value)
        end

        def FloatLiteral(value)
          BasicLit(:FLOAT, value)
        end

      end

      module StatementNodes
        def Statements(node)
          case node
          in SyntaxTree::Command[
            message: SyntaxTree::Ident[value: "require"],
            arguments: SyntaxTree::Args[ parts: [
              SyntaxTree::StringLiteral[
                parts: [SyntaxTree::TStringContent[value: path]]
              ]
            ]]
          ]
            ImportSpec(path)

          in SyntaxTree::VoidStmt
            nil
          else
            nil
          end
        end

        def ImportSpec(path, name: nil)
          SyntaxTree::Go::ImportSpec.new(
            doc: nil,
            name: name,
            path: StringLiteral(path),
            comment: nil,
            end_pos: nil
          )
        end

      end

      def call(node)
        root_context = Context.new(node.statements.body)

        root_context.match do
          before do |ctx|
          end

          iterate do |ctx, node|
            case node
            in SyntaxTree::ModuleDeclaration[
              constant: SyntaxTree::ConstRef[
                constant: SyntaxTree::Const[value: "Main"]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              Hoist.new(body)

            in SyntaxTree::DefNode[
              name: { value: name },
              params: params,
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body).then do |children|
                Function(
                  name: name,
                  params: params,
                  body: children.tree
                )
              end

            in SyntaxTree::Begin[
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body).then do |children|
                Block(body: children.tree)
              end

            in SyntaxTree::IfNode[] |
              SyntaxTree::UnlessNode[] |
              SyntaxTree::WhileNode[] |
              SyntaxTree::UntilNode[] |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[
                message: SyntaxTree::Ident[value: "loop"]
              ]] |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[
                message: SyntaxTree::Ident[value: "each"]
              ]] => logic_node
              Logic(logic_node)

            in SyntaxTree::Comment[value: value]
              Comment(value: value)

            else
              Statements(node)
            end
          end

          after do |ctx|
            if ctx.equal?(root_context)
              file = Package(name: "main", declarations: ctx.tree.dup)
              ctx.tree.replace([file])
            end
          end
        end

        root_context.tree.first
      end
    end

    class Context
      include Runner::PackageNodes
      include Runner::FunctionNodes
      include Runner::BlockNodes
      include Runner::LogicNodes
      include Runner::CommentNodes
      include Runner::VariableNodes
      include Runner::StatementNodes
    end
  end
end
