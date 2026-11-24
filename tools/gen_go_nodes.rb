#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "syntax_tree"

module GoNodeGenerator
  extend SyntaxTree::DSL

  RUBY_KEYWORDS = %w[
    __ENCODING__ __LINE__ __FILE__ BEGIN END alias and begin break case class
    def defined? do else elsif end ensure false for if in module next nil not
    or redo rescue retry return self super then true undef unless until when
    while yield
  ].to_set

  class FieldIdent < SyntaxTree::Ident
    def initialize(value:, location: SyntaxTree::Location.default)
      name = value.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase
      name = "#{name}_" if RUBY_KEYWORDS.include?(name)
      super(value: name, location: location)
    end
  end

  module_function

  def snake(name)
    name.gsub(/([a-z0-9])([A-Z])/, '\1_\2').downcase
  end

  def fname(field)
    FieldIdent.new(value: field["name"]).value
  end

  def default_node(field)
    case field["role"]
    when "children"
      ArrayLiteral(LBracket("["), Args([]))
    when "bool"
      VarRef(Kw("false"))
    else
      VarRef(Kw("nil"))
    end
  end

  def build_program(schema)
    Program(
      Statements(
        [
          ModuleDeclaration(
            ConstPathRef(ConstRef(Const("SyntaxTree")), Const("Go")),
            BodyStmt(
              Statements(
                schema.map do |node|
                  # Positions and parser metadata are not part of tree identity.
                  fields = node["fields"].select do |field|
                    !%w[pos semantic map].include?(field["role"]) &&
                      !%w[doc comment comments imports unresolved go_version].include?(fname(field))
                  end

                  ClassDeclaration(
                    ConstRef(Const(node["name"])),
                    ConstRef(Const("Node")),
                    BodyStmt(
                      Statements(
                        [
                          Assign(
                            ConstRef(Const("SEMANTIC_FIELDS")),
                            CallNode(
                              HashLiteral(
                                LBrace("{"),
                                fields.map do |field|
                                  Assoc(
                                    SymbolLiteral(Ident(fname(field))),
                                    SymbolLiteral(Ident(field["role"]))
                                  )
                                end
                              ),
                              Period("."),
                              Ident("freeze"),
                              nil
                            )
                          ),
                          CallNode(
                            nil,
                            nil,
                            Ident("attr_reader"),
                            ArgParen(
                              Args(
                                (
                                  names = node["fields"].map { |f| fname(f) }
                                  (names + ["location", "comments"]).uniq.map { |n| SymbolLiteral(Ident(n)) }
                                )
                              )
                            )
                          ),
                          DefNode(
                            nil,
                            nil,
                            Ident("initialize"),
                            Params(
                              [],
                              [],
                              nil,
                              [],
                              (
                                names = node["fields"].map { |f| fname(f) }
                                base = []
                                base << [Label("location:"), CallNode(ConstPathRef(ConstRef(Const("SyntaxTree")), Const("Location")), Period("."), Ident("default"), nil)] unless names.include?("location")
                                base << [Label("comments:"), ArrayLiteral(LBracket("["), Args([]))] unless names.include?("comments")
                                node["fields"].map { |f| [Label("#{fname(f)}:"), default_node(f)] } + base
                              ),
                              nil,
                              nil
                            ),
                            BodyStmt(
                              Statements(
                                (
                                names = node["fields"].map { |f| fname(f) }
                                base = []
                                base << Assign(VarField(IVar("@location")), VarRef(Ident("location"))) unless names.include?("location")
                                base << Assign(VarField(IVar("@comments")), VarRef(Ident("comments"))) unless names.include?("comments")
                                node["fields"].map { |f| Assign(VarField(IVar("@#{fname(f)}")), VarRef(Ident(fname(f)))) } + base
                              )
                              ),
                              nil,
                              nil,
                              nil,
                              nil
                            )
                          ),
                          DefNode(
                            nil,
                            nil,
                            Ident("accept"),
                            Params([Ident("visitor")], [], nil, [], [], nil, nil),
                            BodyStmt(
                              Statements(
                                [
                                  CallNode(
                                    VarRef(Ident("visitor")),
                                    Period("."),
                                    Ident("visit_#{snake(node["name"])}"),
                                    ArgParen(Args([VarRef(Kw("self"))]))
                                  )
                                ]
                              ),
                              nil,
                              nil,
                              nil,
                              nil
                            )
                          ),
                          DefNode(
                            nil,
                            nil,
                            Ident("child_nodes"),
                            Params([], [], nil, [], [], nil, nil),
                            BodyStmt(
                              Statements(
                                [
                                  (
                                    children = node["fields"].select { |f| %w[child children].include?(f["role"]) }
                                    if children.empty?
                                      ArrayLiteral(LBracket("["), Args([]))
                                    else
                                      CallNode(
                                        ArrayLiteral(
                                          LBracket("["),
                                          Args(children.map { |f| VarRef(IVar("@#{fname(f)}")) })
                                        ),
                                        Period("."),
                                        Ident("compact"),
                                        nil
                                      )
                                    end
                                  )
                                ]
                              ),
                              nil,
                              nil,
                              nil,
                              nil
                            )
                          ),
                          AliasNode(Ident("deconstruct"), Ident("child_nodes")),
                          DefNode(
                            nil,
                            nil,
                            Ident("deconstruct_keys"),
                            Params([Ident("_keys")], [], nil, [], [], nil, nil),
                            BodyStmt(
                              Statements(
                                [
                                  HashLiteral(LBrace("{"), 
                                    (
                                    names = node["fields"].map { |f| fname(f) }
                                    base = []
                                    base << Assoc(SymbolLiteral(Ident("location")), VarRef(IVar("@location"))) unless names.include?("location")
                                    base << Assoc(SymbolLiteral(Ident("comments")), VarRef(IVar("@comments"))) unless names.include?("comments")
                                    node["fields"].map { |f| Assoc(SymbolLiteral(Ident(fname(f))), VarRef(IVar("@#{fname(f)}"))) } + base
                                  )
                                  )
                                ]
                              ),
                              nil,
                              nil,
                              nil,
                              nil
                            )
                          ),
                          DefNode(
                            nil,
                            nil,
                            Ident("format"),
                            Params([Ident("q")], [], nil, [], [], nil, nil),
                            BodyStmt(
                              Statements(
                                [
                                  CallNode(
                                    CallNode(ConstRef(Const("Format")), Period("."), Ident("new"), ArgParen(Args([VarRef(Ident("q"))]))),
                                    Period("."),
                                    Ident("visit"),
                                    ArgParen(Args([VarRef(Kw("self"))]))
                                  )
                                ]
                              ),
                              nil,
                              nil,
                              nil,
                              nil
                            )
                          )
                        ]
                      ),
                      nil,
                      nil,
                      nil,
                      nil
                    )
                  )
                end
              ),
              nil,
              nil,
              nil,
              nil
            )
          )
        ]
      )
    )
  end
end

if $PROGRAM_NAME == __FILE__
  schema = JSON.parse(ARGV[0] ? File.read(ARGV[0]) : `go run ./tools/ast.go`)
  puts SyntaxTree.format_node("", GoNodeGenerator.build_program(schema))
end
