# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "gob"
require "syntax_tree/go"
require "json"
require "minitest/autorun"

class SyntaxTreeGoTest < Minitest::Test
  def test_equality_ignores_whitespace_and_positions
    first = SyntaxTree::Go.parse("package main; func main() { println(1) }")
    second = SyntaxTree::Go.parse("package main\n\nfunc main() {\n\tprintln(1)\n}\n")
    assert first === second
    assert_equal first.construct_keys, second.construct_keys
  end

  def test_equality_ignores_comments
    first = SyntaxTree::Go.parse("package main\nfunc main() {}\n")
    second = SyntaxTree::Go.parse("// package\npackage main\n// main\nfunc main() { // body\n}\n")
    assert first === second
    assert_equal first.construct_keys, second.construct_keys
  end

  def test_equality_compares_nested_nodes_structurally
    first = SyntaxTree::Go.parse("package main\nfunc main() { println(1 + 2) }\n")
    second = SyntaxTree::Go.parse("package main\nfunc main() { println(1 + 2) }\n")
    assert first === second
  end

  def test_equality_detects_operator_differences
    first = SyntaxTree::Go.parse("package main\nvar x = 1 + 2\n")
    second = SyntaxTree::Go.parse("package main\nvar x = 1 - 2\n")
    refute first === second
  end

  def test_equality_detects_literal_differences
    first = SyntaxTree::Go.parse("package main\nvar x = 1\n")
    second = SyntaxTree::Go.parse("package main\nvar x = 2\n")
    refute first === second
  end

  def test_var_declaration_and_short_declaration_remain_distinct
    declaration = SyntaxTree::Go.parse("package main\nfunc main() { var x = 1; _ = x }\n")
    assignment = SyntaxTree::Go.parse("package main\nfunc main() { x := 1; _ = x }\n")
    refute declaration === assignment
  end

  def test_token_values_compare_across_strings_and_symbols
    first = SyntaxTree::Go::BasicLit.new(kind: "INT", value: "1")
    second = SyntaxTree::Go::BasicLit.new(kind: :INT, value: "1")
    assert first === second
    assert_equal first.construct_keys, second.construct_keys
  end

  def test_identifier_equality_ignores_positions_and_objects
    first = SyntaxTree::Go::Ident.new(name: "value", name_pos: { "line" => 1 })
    second = SyntaxTree::Go::Ident.new(name: "value")
    assert first === second
  end

  def test_generated_ast_matches_reparsed_output
    source = "require \"fmt\"\n\n" \
             "def main\n" \
             "  fmt.Println(\"hi\")\n" \
             "end\n"

    generated = Gob.transpile(source, check: false)
    reparsed = SyntaxTree::Go.parse(Gob::Go::Printer.print(generated))
    assert generated === reparsed
    assert_equal generated.construct_keys, reparsed.construct_keys
  end

  def test_json_contains_only_semantic_fields
    tree = SyntaxTree::Go.parse("package main\nvar x int\n")
    json = JSON.parse(tree.to_json)
    refute_includes json.keys, "location"
    refute_includes json.keys, "comments"
    refute_includes json.keys, "imports"
    refute_includes json.keys, "scope"
    assert_equal "File", json.fetch("type")
    assert_equal "main", json.fetch("name").fetch("name")
  end

  def test_pretty_print_contains_only_semantic_fields
    tree = SyntaxTree::Go.parse("package main\nvar x int\n")
    output = PP.pp(tree, +"")
    refute_includes output, "location:"
    refute_includes output, "name_pos:"
    refute_includes output, "file_start:"
    refute_match(/obj:|scope:|unresolved:/, output)
  end

  def test_visitor_handles_arrays_and_nil
    visitor = NameVisitor.new
    tree = [SyntaxTree::Go::Ident.new(name: "value"), nil]
    assert_equal ["value", nil], visitor.visit(tree)
  end

  class NameVisitor < SyntaxTree::Go::Visitor
    def visit_ident(node)
      node.name
    end
  end
end
