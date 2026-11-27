# frozen_string_literal: true

require_relative "support/syntax_test"

class TagTest < SyntaxTest
  def test_struct_inline_tag
    go = transpile(<<~GOB)
      module Main
        var Person = Struct.new(
          Name: string, # `json:"name"`
        )
      end
    GOB
    assert_includes(go, '`json:"name"`')
  end

  def test_struct_multiple_inline_tags
    go = transpile(<<~GOB)
      module Main
        var Person = Struct.new(
          ID: int, # `json:"id"`
          Name: string, # `json:"name"`
          Age: int, # `json:"age,omitempty"`
        )
      end
    GOB
    assert_includes(go, '`json:"id"`')
    assert_includes(go, '`json:"name"`')
    assert_includes(go, '`json:"age,omitempty"`')
  end

  def test_class_inline_tag
    go = transpile(<<~GOB)
      module Main
        class Person
          attr_accessor :Name, string # `json:"name"`
        end
      end
    GOB
    assert_includes(go, '`json:"name"`')
  end

  def test_class_multiple_inline_tags
    go = transpile(<<~GOB)
      module Main
        class Person
          attr_accessor :ID, int # `json:"id"`
          attr_accessor :Name, string # `json:"name"`
        end
      end
    GOB
    assert_includes(go, '`json:"id"`')
    assert_includes(go, '`json:"name"`')
  end
end
