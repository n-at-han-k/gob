# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "gob"
require "minitest/autorun"

class PointerCastTest < Minitest::Test
  def transpile(src)
    Gob.transpile_to_go(src, path: "test.gob", check: false)
  end

  def test_pointer_cast_simple
    go = transpile(<<~GOB)
      module Main
        def f(p) # (unsafe.Pointer)
          x = @@byte.(p)
        end
      end
    GOB
    assert_includes(go, "(*byte)(p)")
  end

  def test_pointer_cast_qualified_type
    go = transpile(<<~GOB)
      require "unsafe"
      require "example.com/pkg/foo", foo

      module Main
        def f(p) # (unsafe.Pointer)
          x = @@foo.Bar.(p)
        end
      end
    GOB
    assert_includes(go, "(*foo.Bar)(p)")
  end
end
