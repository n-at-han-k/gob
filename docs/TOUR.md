# Language Tour

Gob is Ruby-like syntax that transpiles to Go. You write `.gob` files; Gob emits Go source you can format, build, and run with the Go toolchain through the `gob` CLI.

For runnable, tested examples, see `test/cases/` in the repository.

## Hello, Gob

```ruby
require "fmt"

module Main
  def main
    fmt.Println("hello world")
  end
end
```

`require` becomes a Go import. `module Main` produces `package main`, and `main` is treated specially as Go's entry point.

## Variables

```ruby
module Main
  def main
    var a = "initial"
    var :b, int, 1
    var :c, int, 2
    var d = true
    var :e, int

    f = "apple"
  end
end
```

Use `var name = value` when Go can infer the type, `var :name, Type` for an explicit zero value, and `var :name, Type, value` for an explicit typed value. Short assignment `name = value` becomes `:=` in function bodies.

## Functions and multiple returns

```ruby
module Main
  def plus(a, b) # (int, int) -> int
    return a + b
  end

  def vals # -> (int, int)
    return 3, 7
  end

  def main
    a, b = vals()
    _, c = vals()
  end
end
```

Inline signature comments carry Go parameter and result types. Multiple return values are written and assigned in Go style.

## Collections and iteration

```ruby
require "fmt"

module Main
  def main
    nums = Array[int].new(2, 3, 4)
    m = Hash[string, string].new("a" => "apple", "b" => "banana")

    nums.each do |_, num|
      fmt.Println(num)
    end

    m.each do |k, v|
      fmt.Printf("%s -> %s\n", k, v)
    end

    3.times do |i|
      fmt.Println(i)
    end
  end
end
```

`Array[Type].new(...)` and `Hash[Key, Value].new(...)` create Go slices and maps. `each` over arrays, maps, and strings maps to Go `range`. `count.times do |i|` gives a zero-based counting loop.

## Structs, pointers, and methods

```ruby
module Main
  var person = Struct.new(name: string, age: int) do
    def self.area # -> int
      return 0
    end
  end

  def main
    p = person.new(name: "Ann", age: 40)
    sp = @p
    sp.age = 41
    fmt.Println(@@sp.age)
  end
end
```

`Struct.new(...)` declares a Go struct type. `@value` takes an address; `@@value` dereferences. `def self.Method` inside a struct block declares a pointer-receiver method; a plain `def` inside the block declares a value-receiver method.

## Errors

```ruby
require "errors"
require "fmt"

module Main
  def f(arg) # (int) -> (int, error)
    if arg == 42
      return -1, errors.New("can't work with 42")
    end

    return arg + 3, nil
  end

  def main
    if (r, e = f(7))
      fmt.Println("failed:", e)
    else
      fmt.Println("worked:", r)
    end
  end
end
```

Gob uses Go's error-as-value style. Errors are returned, checked, wrapped, and tested with the standard Go patterns.

## Closures

```ruby
module Main
  def intSeq # -> func() int
    i = 0
    return lambda { || # () -> int
      i = i + 1
      return i
    }
  end
end
```

Lambdas become Go function literals. Lambda parameter and result types are carried by inline comments.

## Concurrency

```ruby
require "fmt"
require "time"

module Main
  def main
    messages = make(Chan[string])

    go lambda {
      messages << "ping"
    }.()

    msg = ~messages
    fmt.Println(msg)
  end
end
```

`go` starts a goroutine. `Chan[T]`/`make(Chan[T])` create channels. `<<` sends, and `~channel` receives. `case/when` over channel receives maps to Go `select`.

## Next steps

- Read `README.md` and `DEVELOPMENT.md` for setup and workflow.
- Browse `test/cases/` for the golden Gob/Go pairs that define supported behavior.
- Use `gob fmt`, `gob vet`, `gob transpile`, `gob build`, and `gob run`.
