# frozen_string_literal: true

require_relative "support/syntax_test"

class ChannelAndBitwiseTest < SyntaxTest

  def test_channel_receive_no_arg
    go = transpile(<<~GOB)
      module Main
        def f(ch) # (Chan[int])
          v = ch.<<
        end
      end
    GOB
    assert_includes(go, "v := <-ch")
  end

  def test_channel_receive_with_ok
    go = transpile(<<~GOB)
      module Main
        def f(ch) # (Chan[int])
          v, ok = ch.<<
        end
      end
    GOB
    assert_includes(go, "v, ok := <-ch")
  end

  def test_channel_send_paren
    go = transpile(<<~GOB)
      module Main
        def f(ch) # (Chan[int])
          ch.<<(1)
        end
      end
    GOB
    assert_includes(go, "ch <- 1")
  end

  def test_channel_send_command
    go = transpile(<<~GOB)
      module Main
        def f(ch) # (Chan[int])
          ch.<< 1
        end
      end
    GOB
    assert_includes(go, "ch <- 1")
  end

  def test_channel_send_binary_still_works
    go = transpile(<<~GOB)
      module Main
        def f(ch) # (Chan[int])
          ch << 1
        end
      end
    GOB
    assert_includes(go, "ch <- 1")
  end

  def test_select_receive_new_syntax
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
    assert_includes(go, "case msg := <-ch:")
  end

  def test_select_send_new_syntax
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch, msg) # (Chan[string], string)
          case
          when ch.<<(msg)
            fmt.Println("sent")
          else
            fmt.Println("no")
          end
        end
      end
    GOB
    assert_includes(go, "case ch <- msg:")
  end

  def test_select_send_binary_in_when
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(events, event) # (Chan[string], string)
          case
          when events << event
            fmt.Println("sent")
          when ctx.Done().<<
            fmt.Println("done")
          end
        end
      end
    GOB
    assert_includes(go, "select {")
    assert_includes(go, "case events <- event:")
    assert_includes(go, "case <-ctx.Done():")
  end

  def test_select_receive_bare_in_when
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when ch.<<
            fmt.Println("got")
          end
        end
      end
    GOB
    assert_includes(go, "case <-ch:")
  end

  def test_select_send_binary_in_when_arrow
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(events, event) # (Chan[string], string)
          case
          when events.←.event
            fmt.Println("sent")
          when ←.ctx.Done()
            fmt.Println("done")
          end
        end
      end
    GOB
    assert_includes(go, "select {")
    assert_includes(go, "case events <- event:")
    assert_includes(go, "case <-ctx.Done():")
  end

  def test_select_receive_bare_in_when_arrow
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when ←.ch
            fmt.Println("got")
          end
        end
      end
    GOB
    assert_includes(go, "case <-ch:")
  end

  def test_bitwise_not
    go = transpile(<<~GOB)
      module Main
        def f(x) # (int) -> int
          return ~x
        end
      end
    GOB
    assert_includes(go, "^x")
  end

  def test_bit_clear
    go = transpile(<<~GOB)
      module Main
        def f(a, b) # (int, int) -> int
          return a &! b
        end
      end
    GOB
    assert_includes(go, "a &^ b")
  end

  def test_arrow_receive
    go = transpile(<<~GOB)
      module Main
        def f(ch) # (Chan[int])
          v = ←ch
        end
      end
    GOB
    assert_includes(go, "v := <-ch")
  end

  def test_arrow_send
    go = transpile(<<~GOB)
      module Main
        def f(ch) # (Chan[int])
          ch ← 1
        end
      end
    GOB
    assert_includes(go, "ch <- 1")
  end
end
