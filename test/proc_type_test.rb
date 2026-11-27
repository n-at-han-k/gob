# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "gob"
require "minitest/autorun"

class ProcTypeTest < Minitest::Test
  def transpile(src)
    Gob.transpile_to_go(src, path: "test.gob", check: false)
  end

  def test_proc_no_params_single_return
    go = transpile(<<~GOB)
      module Main
        var :f, Proc[[bool]]
      end
    GOB
    assert_includes(go, "var f func() (bool)")
  end

  def test_proc_one_param_single_return
    go = transpile(<<~GOB)
      module Main
        var :f, Proc[int, [bool]]
      end
    GOB
    assert_includes(go, "var f func(int) (bool)")
  end

  def test_proc_two_params_single_return
    go = transpile(<<~GOB)
      module Main
        var :f, Proc[int, string, [bool]]
      end
    GOB
    assert_includes(go, "var f func(int, string) (bool)")
  end

  def test_proc_multiple_returns
    go = transpile(<<~GOB)
      module Main
        var :f, Proc[int, [bool, error]]
      end
    GOB
    assert_includes(go, "var f func(int) (bool, error)")
  end
end
