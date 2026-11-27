# frozen_string_literal: true

require_relative "support/syntax_test"

class ComplexTypeTest < SyntaxTest

  def test_nested_array
    go = transpile(<<~GOB)
      module Main
        var :x, Array[Array[int]]
      end
    GOB
    assert_includes(go, "var x [][]int")
  end

  def test_nested_hash_value
    go = transpile(<<~GOB)
      module Main
        var :x, Hash[string, Array[int]]
      end
    GOB
    assert_includes(go, "var x map[string][]int")
  end

  def test_nested_hash_hash
    go = transpile(<<~GOB)
      module Main
        var :x, Hash[string, Hash[string, int]]
      end
    GOB
    assert_includes(go, "var x map[string]map[string]int")
  end

  def test_array_of_hash
    go = transpile(<<~GOB)
      module Main
        var :x, Array[Hash[string, int]]
      end
    GOB
    assert_includes(go, "var x []map[string]int")
  end

  def test_hash_with_proc_value
    go = transpile(<<~GOB)
      module Main
        var :x, Hash[string, Proc[int, [bool]]]
      end
    GOB
    assert_includes(go, "var x map[string]func(int) bool")
  end

  def test_deeply_nested_hash_array
    go = transpile(<<~GOB)
      module Main
        var :x, Hash[string, Array[Hash[string, int]]]
      end
    GOB
    assert_includes(go, "var x map[string][]map[string]int")
  end

  def test_fixed_array_of_arrays
    go = transpile(<<~GOB)
      module Main
        var :x, Array[Array[int, 4], 8]
      end
    GOB
    assert_includes(go, "var x [8][4]int")
  end

  def test_empty_struct_type
    go = transpile(<<~GOB)
      module Main
        var :x, Struct[]
      end
    GOB
    assert_includes(go, "var x struct {}")
  end

  def test_empty_class_type_alias
    go = transpile(<<~GOB)
      module Main
        var :x, Class[]
      end
    GOB
    assert_includes(go, "var x struct {}")
  end

  def test_bare_struct_type
    go = transpile(<<~GOB)
      module Main
        var :x, Struct
      end
    GOB
    assert_includes(go, "var x struct {}")
  end

  def test_class_new_array_of_struct
    go = transpile(<<~GOB)
      module Main
        var armFits = Class.new(Array[struct, 1])
      end
    GOB
    assert_includes(go, "type armFits [1]struct {}")
  end
end
