# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../../lib", __dir__))

require "gob"
require "syntax_tree"
require "syntax_tree/go"
require "minitest/autorun"
require "minitest/reporters"
require_relative "syntax_reporter"

Minitest::Reporters.use! [Gob::SyntaxReporter.new(color: true, location: true)]

class SyntaxTest < Minitest::Test
  def transpile(src)
    @last_source = src
    @last_ruby_ast = SyntaxTree.parse(src)
    Gob.transpile_to_go(src, path: "test.gob", check: false)
  end

  def assert_includes(collection, obj, msg = nil)
    super
  rescue Minitest::Assertion => e
    raise e unless @last_source && collection.is_a?(String) && obj.is_a?(String)

    emitted_ast = begin
      SyntaxTree::Go.parse(collection)
    rescue
      nil
    end

    expected_ast = begin
      SyntaxTree::Go.parse(obj)
    rescue
      obj
    end

    raise Gob::SyntaxMismatch.new(
      source: @last_source,
      ruby_ast: @last_ruby_ast,
      expected: obj,
      expected_ast: expected_ast,
      emitted: collection,
      emitted_ast: emitted_ast
    )
  end
end
