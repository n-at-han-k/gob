# frozen_string_literal: true

require_relative "support/syntax_test"

class LambdaTest < SyntaxTest

  # A lambda is a Go function literal, and its signature comment carries the
  # types Ruby cannot.
  # ---
  def test_lambda_no_params
    go = transpile(<<~GOB)
      module Main
        def main
          f = lambda {
            fmt.Println("hi")
          }
        end
      end
    GOB
    assert_includes(go, "f := func()")
  end

  def test_lambda_params_from_signature
    go = transpile(<<~GOB)
      module Main
        def main
          double = lambda { |value| # (int) -> int
            return value * 2
          }
        end
      end
    GOB
    assert_includes(go, "double := func(value int) int {")
  end

  def test_lambda_two_params
    go = transpile(<<~GOB)
      module Main
        def main
          cmp = lambda { |a, b| # (string, string) -> int
            return 0
          }
        end
      end
    GOB
    assert_includes(go, "cmp := func(a string, b string) int {")
  end

  def test_lambda_multiple_results
    go = transpile(<<~GOB)
      module Main
        def main
          parse = lambda { |text| # (string) -> (int, error)
            return 0, nil
          }
        end
      end
    GOB
    assert_includes(go, "parse := func(text string) (int, error) {")
  end

  def test_lambda_no_params_with_result
    go = transpile(<<~GOB)
      module Main
        def counter # -> Proc[[int]]
          return lambda { || # () -> int
            return 1
          }
        end
      end
    GOB
    assert_includes(go, "return func() int {")
  end

  def test_lambda_as_argument
    go = transpile(<<~GOB)
      module Main
        def main
          slices.SortFunc(people, lambda { |a, b| # (person, person) -> int
            return 0
          })
        end
      end
    GOB
    assert_includes(go, "slices.SortFunc(people, func(a person, b person) int {")
  end

  # A goroutine takes a call, and a lambda is only needed when the goroutine
  # body is more than one.
  # ---
  def test_go_call
    go = transpile(<<~GOB)
      module Main
        def main
          go syncer.Run(ctx)
        end
      end
    GOB
    assert_includes(go, "go syncer.Run(ctx)")
  end

  def test_go_lambda
    go = transpile(<<~GOB)
      module Main
        def main
          go lambda {
            fmt.Println("one")
            fmt.Println("two")
          }.()
        end
      end
    GOB
    assert_includes(go, "go func()")
  end

  def test_lambda_in_goroutine_is_not_wrapped_twice
    go = transpile(<<~GOB)
      module Main
        def main
          go openvfs.ServeAPI(ctx, socketPath, lambda { |event| # (directory.Event)
            fmt.Println(event)
          })
        end
      end
    GOB
    assert_includes(go, "go openvfs.ServeAPI(ctx, socketPath, func(event directory.Event) {")
  end
end
