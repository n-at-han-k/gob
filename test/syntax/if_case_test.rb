# frozen_string_literal: true

require_relative "support/syntax_test"

class IfCaseTest < SyntaxTest

  def test_if_err_magic
    go = transpile(<<~GOB)
      module Main
        def f(err) # (error) -> bool
          if err
            return true
          end
          return false
        end
      end
    GOB
    assert_includes(go, "if err != nil {")
  end

  def test_unless_err_magic
    go = transpile(<<~GOB)
      module Main
        def f(err) # (error) -> bool
          unless err
            return true
          end
          return false
        end
      end
    GOB
    assert_includes(go, "if err == nil {")
  end

  def test_if_assign_guard
    go = transpile(<<~GOB)
      module Main
        def f(m) # (Hash[string, int]) -> int
          if v = m["k"]
            return v
          end
          return 0
        end
      end
    GOB
    assert_includes(go, "if v := m[\"k\"]; v {")
  end

  def test_if_assign_and_guard
    go = transpile(<<~GOB)
      module Main
        def f(m) # (Hash[string, int]) -> int
          if v = m["k"] && v > 0
            return v
          end
          return 0
        end
      end
    GOB
    assert_includes(go, "if v := m[\"k\"]; v > 0 {")
  end

  def test_if_massign_guard
    go = transpile(<<~GOB)
      module Main
        def f(m) # (Hash[string, int]) -> int
          if (v, ok = m["k"])
            return v
          end
          return 0
        end
      end
    GOB
    assert_includes(go, "if v, ok := m[\"k\"]; ok {")
  end

  def test_if_elsif_else
    go = transpile(<<~GOB)
      module Main
        def f(x) # (int) -> string
          if x > 0
            return "pos"
          elsif x < 0
            return "neg"
          else
            return "zero"
          end
        end
      end
    GOB
    assert_includes(go, "if x > 0 {")
    assert_includes(go, "} else if x < 0 {")
    assert_includes(go, "} else {")
  end

  def test_case_value_switch
    go = transpile(<<~GOB)
      module Main
        def f(x) # (int) -> string
          case x
          when 1
            return "one"
          when 2
            return "two"
          else
            return "other"
          end
        end
      end
    GOB
    assert_includes(go, "switch x {")
    assert_includes(go, "case 1:")
    assert_includes(go, "case 2:")
    assert_includes(go, "default:")
  end

  def test_case_type_switch
    go = transpile(<<~GOB)
      module Main
        def f(x) # (any) -> string
          case v = x.(type)
          when string
            return v
          when int
            return "int"
          else
            return "other"
          end
        end
      end
    GOB
    assert_includes(go, "switch v := x.(type) {")
    assert_includes(go, "case string:")
    assert_includes(go, "case int:")
    assert_includes(go, "default:")
  end

  def test_case_select_no_subject
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when msg = ch.<<
            fmt.Println(msg)
          else
            fmt.Println("none")
          end
        end
      end
    GOB
    assert_includes(go, "select {")
    assert_includes(go, "case msg := <-ch:")
    assert_includes(go, "default:")
  end
end
