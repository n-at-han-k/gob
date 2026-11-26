# Gob Specification

This document describes the Gob syntax supported by the current implementation. The authoritative behavior is the golden cases in `test/cases/` and the official transpiler in `lib/gob/transpilation/runner.rb`.

## Files and packages

- Gob source files use the `.gob` extension.
- `require "pkg"` imports a Go package.
- `module Main` declares `package main`; other module names declare that package name (for example `module Ksuid` -> `package ksuid`).
- Top-level `def main` is treated as Go `func main()`.

```ruby
require "fmt"

module Main
  def main
    fmt.Println("hello world")
  end
end
```

## Variables and constants

```ruby
var a = "initial"          # inferred var
var :b, int, 1             # explicit typed var with value
var :c, int                # explicit typed zero value
f = "apple"                # short assignment in function body
```

`var` forms declare Go variables. Plain assignment in a function body maps to Go short declaration where appropriate. Compound assignments such as `+=` are supported where golden cases use them.

Constants use `const :name, value`:

```ruby
const :numJobs, 5
const :s, "hello"
```

Module-level uppercase names and `var` declarations follow Go package declarations as shown in golden cases.

## Functions

```ruby
def plus(a, b) # (int, int) -> int
  return a + b
end

def vals # -> (int, int)
  return 3, 7
end
```

- Function bodies use `def ... end`.
- Go parameter/result types are supplied in inline signature comments.
- Multiple return values are supported.

## Lambdas

```ruby
double = lambda { |value| # (int) -> int
  return value * 2
}
```

Lambdas transpile to Go function literals. Type comments carry parameter and result types. Lambdas may be invoked immediately, for example `go lambda { ... }.()`.

## Control flow and loops

Gob uses Ruby-style blocks with `end`.

```ruby
if err != nil
  fmt.Println(err)
elsif other
  fmt.Println(other)
else
  fmt.Println("ok")
end
```

`if err` and `if (name = expr)` follow Go-style condition/error-check patterns as shown in golden cases.

Loops and control statements:

```ruby
while i < len(s)
  i = i + 1
end

loop do
  break
end

next
```

- `while` maps to a Go `for` condition loop.
- `loop do` maps to an infinite Go `for {}` loop.
- `break` and `next` map to Go `break` and `continue`.

Iteration forms in golden cases include:

```ruby
3.times do |i| ... end              # counting loop
nums.each do |_, num| ... end       # range over slice/array
kvs.each do |k, v| ... end          # range over map
"go".each do |i, c| ... end         # range over string
```

`defer` schedules cleanup:

```ruby
defer file.Close()
```

## Case, switch, and select

`case` maps to Go `switch` or `select` depending on form.

```ruby
case len(b)                # value switch
when 0
  return nil
else
  return err
end

case v = src.(type)        # type switch
when nil
  return self.scan(nil)
when Array[byte]
  return self.scan(v)
else
  return fmt.Errorf("type %T", v)
end
```

A `case` with no expression and channel `when` clauses becomes a Go `select` (see Concurrency).

## Collections

```ruby
nums = Array[int].new(2, 3, 4)
m = Hash[string, int].new("foo" => 1, "bar" => 2)
s = make(Array[string], 3)
c = make(Hash[string, int])
```

- `Array[T].new(...)` creates a Go slice literal.
- `Hash[K, V].new(...)` creates a Go map literal.
- `Array[T, N].new(...)` creates a Go fixed-size array literal.
- `make(Array[T], n)` and `make(Hash[K, V])` map to Go `make`.
- Common Go builtins/helpers used in cases include `len`, `cap`, `append`, `copy`, `delete`, and `clear`.

## Structs and classes

```ruby
var person = Struct.new(name: string, age: int) do
  def self.Rename(name) # (string)
    self.name = name
  end

  def Display # -> string
    return self.name
  end
end
```

- `Struct.new(...)` declares a Go struct type.
- Struct field tags can be placed in a comment immediately before the field:

  ```ruby
  var article = Struct.new(
    # `json:"title"`
    Title: string,
  )
  ```

- `def self.Method` inside a struct/class block declares a pointer receiver.
- Plain `def` inside the block declares a value receiver.
- Struct literals use `person.new(name: "Ann", age: 40)` or positional fields as shown in cases.

`class` declares a named struct type with `attr_accessor` fields:

```ruby
class Args
  attr_accessor :A, int
  attr_accessor :B, int
end
```

Class methods follow the same receiver rule: `def self.Method` for pointer receivers, `def Method` for value receivers. Instantiate with `ClassName.new(...)`, like struct literals.

## Pointers

```ruby
p = @value   # address-of
v = @@p      # dereference
```

`@` maps to Go `&`. `@@` maps to Go `*` for dereference.

## Errors

Gob follows Go error conventions. Functions return `error` values, callers check them, and helpers such as `errors.New`, `fmt.Errorf`, and `errors.Is` are used as in Go.

```ruby
if (r, e = f(i))
  fmt.Println("failed:", e)
else
  fmt.Println("worked:", r)
end
```

## Concurrency

```ruby
messages = make(Chan[string])
jobs = make(Chan[int], 5)

go lambda { messages << "ping" }.()

msg = ~messages
j, more = ~jobs
close(jobs)
```

- `go` starts a goroutine.
- `Chan[T]` is the Gob channel type form; direction types use Go-style forms in signatures, such as `<-chan int` and `chan<- int`.
- `make(Chan[T])` or `make(Chan[T], n)` creates an unbuffered or buffered channel.
- `ch << value` sends.
- `~ch` receives; `value, ok = ~ch` checks whether the channel is still open.
- `close(ch)` closes a channel.

`case/when` with channel receives maps to Go `select`:

```ruby
case
when msg = ~c1
  fmt.Println(msg)
when ~time.After(time.Second)
  fmt.Println("timeout")
end
```

## Style and validation

- Prefer explicit Gob types and supported forms.
- Run `gob fmt --write` and `gob vet` on `.gob` files.
- Use `test/cases/` as the reference for supported syntax and expected Go output.