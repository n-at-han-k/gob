# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "syntax_tree"
require "gob/validation/rules"
require "minitest/autorun"

class ValidationRulesTest < Minitest::Test
  def test_trailing_whitespace
    assert_equal "x = 1\ny = 2\n", autocorrect("x = 1  \ny = 2\t\n")
  end

  def test_variable_declaration
    assert_equal "var :x, int\n", autocorrect("define_var :x, int\n")
  end

  def test_pointer_type
    assert_equal "var :x, @@Type\n", autocorrect("var :x, ptr(Type)\n")
  end

  def test_operator_assignment
    assert_equal "x = x + 1\n", autocorrect("x += 1\n")
  end

  def test_zero_based_range_loop
    assert_equal "count.times do |i|\n  puts i\nend\n", autocorrect("(0...count).each do |i|\n  puts i\nend\n")
  end

  def test_word_array
    assert_equal "Array[string].new(\"one\", \"two\").each do |word|\n  puts word\nend\n", autocorrect("%w[one two].each do |word|\n  puts word\nend\n")
  end

  def test_go_block
    assert_equal "go lambda {\n  work\n}.()\n", autocorrect("go do\n  work\nend.()\n")
  end

  def test_redundant_lambda_parentheses
    assert_equal "return lambda do\n  work\nend\n", autocorrect("return(\n  lambda do\n    work\n  end\n)\n")
  end

  def test_this_receiver
    assert_equal "self.Value\n@self = value\n", autocorrect("this.Value\n@this = value\n")
  end

  def test_array_length
    assert_equal "var :x, Array[byte, 1048576]\n", autocorrect("var :x, Array[byte, 1 << 20]\n")
  end

  def test_collection_literals
    assert_equal "x = Array[int].new(1, 2)\n", autocorrect("x = [1, 2]\n")
    assert_equal "x = Hash[string, int].new(\"a\" => 1)\n", autocorrect("x = { \"a\" => 1 }\n")
  end

  def test_collection_literals_inside_typed_new_are_not_enforced
    source = "x = Array[Array[int]].new([1, 2], [3, 4])\n"
    assert_equal source, autocorrect(source)
    refute_includes offense_names(source), "Gob/CollectionLiteral"

    hash_source = "x = Hash[string, Array[int]].new(\"a\" => [1, 2])\n"
    assert_equal hash_source, autocorrect(hash_source)
    refute_includes offense_names(hash_source), "Gob/CollectionLiteral"
  end

  def test_select_block
    expected = "case\nwhen ~ready()\n  return value\nend\n"
    assert_equal expected, autocorrect("select do |c|\n  c << ready() { return value }\nend\n")
  end

  def test_lambda_signature_is_required
    assert_includes offense_names("x = lambda { |value| value > 0 }\n"), "Gob/LambdaSignature"
    refute_includes offense_names("x = lambda { |value| # (int) -> bool\n  value > 0\n}\n"), "Gob/LambdaSignature"
  end

  def test_invoked_lambda_is_rejected_except_after_go
    assert_includes offense_names("x = lambda { work }.()\n"), "Gob/InvokedLambda"
    refute_includes offense_names("go lambda { work }.()\n"), "Gob/InvokedLambda"
  end

  def test_attribute_type_is_required
    assert_includes offense_names("class X\n  attr_accessor :Name\nend\n"), "Gob/AttributeType"
  end

  def test_go_call
    assert_equal "go lambda {\n  srv.Accept(listener)\n}.()\n", autocorrect("go srv.Accept(listener)\n")
  end

  def test_struct_tag_position
    source = "var x = Struct.new(\n  Name: string, # `json:\"name\"`\n)\n"
    expected = "var x = Struct.new(\n  # `json:\"name\"`\n  Name: string,\n)\n"
    assert_equal expected, autocorrect(source)
  end

  private

    def autocorrect(source)
      Gob::Validation::Rules.autocorrect(source)
    end

    def offense_names(source)
      Gob::Validation::Rules.validate(source).map(&:cop_name)
    end
end
