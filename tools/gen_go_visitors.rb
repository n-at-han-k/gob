#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "syntax_tree"

module GoVisitorGenerator
  extend SyntaxTree::DSL

  module_function

  def snake(name)
    name.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase
  end

  def visit_alias(node_name)
    AliasNode(Ident("visit_#{snake(node_name)}"), Ident("visit_child_nodes"))
  end

  def build_visitor(schema)
    Program(
      Statements(
        [
          ModuleDeclaration(
            ConstPathRef(ConstRef(Const("SyntaxTree")), Const("Go")),
            BodyStmt(
              Statements(
                [
                  ClassDeclaration(
                    ConstRef(Const("Visitor")),
                    ConstPathRef(ConstRef(Const("SyntaxTree")), Const("BasicVisitor")),
                    BodyStmt(Statements(schema.map { |n| visit_alias(n["name"]) }), nil, nil, nil, nil)
                  )
                ]
              ),
              nil, nil, nil, nil
            )
          )
        ]
      )
    )
  end

  def build_format(schema)
    Program(
      Statements(
        [
          ModuleDeclaration(
            ConstPathRef(ConstRef(Const("SyntaxTree")), Const("Go")),
            BodyStmt(
              Statements(
                [
                  ClassDeclaration(
                    ConstRef(Const("Format")),
                    ConstRef(Const("Visitor")),
                    BodyStmt(
                      Statements(
                        [
                          CallNode(nil, nil, Ident("attr_reader"), ArgParen(Args([SymbolLiteral(Ident("q"))]))),
                          DefNode(
                            nil, nil, Ident("initialize"),
                            Params([Ident("q")], [], nil, [], [], nil, nil),
                            BodyStmt(Statements([Assign(VarField(IVar("@q")), VarRef(Ident("q")))]), nil, nil, nil, nil)
                          )
                        ] + schema.map do |n|
                          DefNode(
                            nil, nil, Ident("visit_#{snake(n["name"])}"),
                            Params([Ident("node")], [], nil, [], [], nil, nil),
                            BodyStmt(
                              Statements([
                                CallNode(VarRef(IVar("@q")), Period("."), Ident("text"), ArgParen(Args([CallNode(VarRef(Ident("node")), Period("."), Ident("class"), ArgParen(Args([ConstRef(Const("name"))])))])))
                              ]),
                              nil, nil, nil, nil
                            )
                          )
                        end
                      ),
                      nil, nil, nil, nil
                    )
                  )
                ]
              ),
              nil, nil, nil, nil
            )
          )
        ]
      )
    )
  end

  def build_simple_subclass(schema, class_name, base, extra_body = [])
    Program(
      Statements(
        [
          ModuleDeclaration(
            ConstPathRef(ConstRef(Const("SyntaxTree")), Const("Go")),
            BodyStmt(
              Statements(
                [
                  ClassDeclaration(
                    ConstRef(Const(class_name)),
                    ConstRef(Const(base)),
                    BodyStmt(Statements(extra_body), nil, nil, nil, nil)
                  )
                ]
              ),
              nil, nil, nil, nil
            )
          )
        ]
      )
    )
  end

  def write(path, program)
    File.write(path, SyntaxTree.format_node("", program))
    puts "wrote #{path}"
  end
end

if $PROGRAM_NAME == __FILE__
  schema = JSON.parse(ARGV[0] ? File.read(ARGV[0]) : `go run ./tools/ast.go`)
  root = File.expand_path("..", __dir__)

  GoVisitorGenerator.write(
    File.join(root, "lib/syntax_tree/go/visitor.rb"),
    GoVisitorGenerator.build_visitor(schema)
  )

  GoVisitorGenerator.write(
    File.join(root, "lib/syntax_tree/go/format.rb"),
    GoVisitorGenerator.build_format(schema)
  )

  q_attr = -> {
    [
      GoVisitorGenerator.CallNode(nil, nil, GoVisitorGenerator.Ident("attr_reader"), GoVisitorGenerator.ArgParen(GoVisitorGenerator.Args([GoVisitorGenerator.SymbolLiteral(GoVisitorGenerator.Ident("q"))]))),
      GoVisitorGenerator.DefNode(
        nil, nil, GoVisitorGenerator.Ident("initialize"),
        GoVisitorGenerator.Params([GoVisitorGenerator.Ident("q")], [], nil, [], [], nil, nil),
        GoVisitorGenerator.BodyStmt(GoVisitorGenerator.Statements([
          GoVisitorGenerator.Assign(GoVisitorGenerator.VarField(GoVisitorGenerator.IVar("@q")), GoVisitorGenerator.VarRef(GoVisitorGenerator.Ident("q")))
        ]), nil, nil, nil, nil)
      )
    ]
  }

  GoVisitorGenerator.write(
    File.join(root, "lib/syntax_tree/go/pretty_print_visitor.rb"),
    GoVisitorGenerator.build_simple_subclass(schema, "PrettyPrintVisitor", "Visitor", q_attr.call)
  )

  GoVisitorGenerator.write(
    File.join(root, "lib/syntax_tree/go/json_visitor.rb"),
    GoVisitorGenerator.build_simple_subclass(schema, "JSONVisitor", "Visitor")
  )

  GoVisitorGenerator.write(
    File.join(root, "lib/syntax_tree/go/match_visitor.rb"),
    GoVisitorGenerator.build_simple_subclass(schema, "MatchVisitor", "Visitor", q_attr.call)
  )
end
