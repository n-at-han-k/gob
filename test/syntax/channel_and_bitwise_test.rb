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

  # A comma-ok receive is legal in a select case, exactly as it is in a plain
  # assignment. It must emit "case v, ok := <-ch:" and must not be dropped.
  def test_select_receive_with_ok_in_when
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when v, ok = ch.<<
            fmt.Println(v, ok)
          end
        end
      end
    GOB
    assert_includes(go, "case v, ok := <-ch:")
  end

  def test_select_receive_with_ok_in_when_arrow
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when v, ok = ←.ch
            fmt.Println(v, ok)
          end
        end
      end
    GOB
    assert_includes(go, "case v, ok := <-ch:")
  end

  # A comma-ok case must not truncate the select: the cases written before and
  # after it have to survive too.
  def test_select_keeps_cases_around_comma_ok
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(a, b, c) # (Chan[int], Chan[int], Chan[int])
          case
          when x = a.<<
            fmt.Println("a", x)
          when y, ok = b.<<
            fmt.Println("b", y, ok)
          when z = c.<<
            fmt.Println("c", z)
          end
        end
      end
    GOB
    assert_includes(go, "case x := <-a:")
    assert_includes(go, "case y, ok := <-b:")
    assert_includes(go, "case z := <-c:")
  end

  def test_select_keeps_cases_around_comma_ok_arrow
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(a, b, c) # (Chan[int], Chan[int], Chan[int])
          case
          when x = ←.a
            fmt.Println("a", x)
          when y, ok = ←.b
            fmt.Println("b", y, ok)
          when z = ←.c
            fmt.Println("c", z)
          end
        end
      end
    GOB
    assert_includes(go, "case x := <-a:")
    assert_includes(go, "case y, ok := <-b:")
    assert_includes(go, "case z := <-c:")
  end

  # The worker loop shape: a queue drained with comma-ok alongside a context
  # cancellation case. Dropping either case turns this into a deadlock.
  def test_select_comma_ok_with_ctx_done
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(queue, ctx) # (Chan[string], context.Context)
          case
          when event, ok = queue.<<
            fmt.Println(event, ok)
          when ctx.Done().<<
            fmt.Println("done")
          end
        end
      end
    GOB
    assert_includes(go, "case event, ok := <-queue:")
    assert_includes(go, "case <-ctx.Done():")
  end

  def test_select_comma_ok_with_ctx_done_arrow
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(queue, ctx) # (Chan[string], context.Context)
          case
          when event, ok = ←.queue
            fmt.Println(event, ok)
          when ←.ctx.Done()
            fmt.Println("done")
          end
        end
      end
    GOB
    assert_includes(go, "case event, ok := <-queue:")
    assert_includes(go, "case <-ctx.Done():")
  end

  def test_channel_receive_with_ok_arrow
    go = transpile(<<~GOB)
      module Main
        def f(ch) # (Chan[int])
          v, ok = ←ch
        end
      end
    GOB
    assert_includes(go, "v, ok := <-ch")
  end

  def test_select_receive_with_ok_and_default
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when v, ok = ch.<<
            fmt.Println(v, ok)
          else
            fmt.Println("none")
          end
        end
      end
    GOB
    assert_includes(go, "case v, ok := <-ch:")
    assert_includes(go, "default:")
  end

  # Bracketed comm clauses. A select case accepts the same parenthesised
  # assignment form as "if (err = f())", for both receive spellings and with or
  # without the ok result.
  def test_select_receive_bracketed
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when (v = ch.<<)
            fmt.Println(v)
          end
        end
      end
    GOB
    assert_includes(go, "case v := <-ch:")
  end

  def test_select_receive_with_ok_bracketed
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when (v, ok = ch.<<)
            fmt.Println(v, ok)
          end
        end
      end
    GOB
    assert_includes(go, "case v, ok := <-ch:")
  end

  def test_select_receive_bracketed_arrow
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when (v = ←.ch)
            fmt.Println(v)
          end
        end
      end
    GOB
    assert_includes(go, "case v := <-ch:")
  end

  def test_select_receive_with_ok_bracketed_arrow
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when (v, ok = ←.ch)
            fmt.Println(v, ok)
          end
        end
      end
    GOB
    assert_includes(go, "case v, ok := <-ch:")
  end

  def test_select_bracketed_keeps_cases_around_comma_ok
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(a, b, c) # (Chan[int], Chan[int], Chan[int])
          case
          when (x = a.<<)
            fmt.Println("a", x)
          when (y, ok = b.<<)
            fmt.Println("b", y, ok)
          when (z = c.<<)
            fmt.Println("c", z)
          end
        end
      end
    GOB
    assert_includes(go, "case x := <-a:")
    assert_includes(go, "case y, ok := <-b:")
    assert_includes(go, "case z := <-c:")
  end

  def test_select_bracketed_comma_ok_with_ctx_done
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(queue, ctx) # (Chan[string], context.Context)
          case
          when (event, ok = queue.<<)
            fmt.Println(event, ok)
          when ctx.Done().<<
            fmt.Println("done")
          end
        end
      end
    GOB
    assert_includes(go, "case event, ok := <-queue:")
    assert_includes(go, "case <-ctx.Done():")
  end

  def test_select_bracketed_comma_ok_with_ctx_done_arrow
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(queue, ctx) # (Chan[string], context.Context)
          case
          when (event, ok = ←.queue)
            fmt.Println(event, ok)
          when ←.ctx.Done()
            fmt.Println("done")
          end
        end
      end
    GOB
    assert_includes(go, "case event, ok := <-queue:")
    assert_includes(go, "case <-ctx.Done():")
  end

  def test_select_bracketed_receive_with_ok_and_default
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch) # (Chan[string])
          case
          when (v, ok = ch.<<)
            fmt.Println(v, ok)
          else
            fmt.Println("none")
          end
        end
      end
    GOB
    assert_includes(go, "case v, ok := <-ch:")
    assert_includes(go, "default:")
  end

  # The bracketed send must keep working alongside the bracketed receives.
  def test_select_send_bracketed
    go = transpile(<<~GOB)
      require "fmt"

      module Main
        def f(ch, msg) # (Chan[string], string)
          case
          when (ch.<<(msg))
            fmt.Println("sent")
          end
        end
      end
    GOB
    assert_includes(go, "case ch <- msg:")
  end
end
