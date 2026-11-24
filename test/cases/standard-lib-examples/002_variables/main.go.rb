require "fmt"

module Main
  # Package-level constants
  PI = 3.14159
  STATUS_ACTIVE = "active"
  STATUS_INACTIVE = "inactive"

  # Package-level variable
  packageLevel = "I live at package scope"

  def main
    # Zero-value typed declarations
    define_var :a, :int
    define_var :b, :string
    define_var :c, :bool
    define_var :d, :float64
    fmt.Println("zero values:", a, b, c, d)

    # Short declaration / inference
    name = "Nathan"
    age = 30
    fmt.Println(name, age)

    # Multiple assignment
    city = "Wellington"
    country = "New Zealand"
    fmt.Println(city, country)

    x, y, z = 1, 2.5, "three"
    fmt.Println(x, y, z)

    x, y = 10, 20.5
    fmt.Println(x, y)

    # Grouped vars in Go original; represented as separate decls
    host = "localhost"
    port = 8080
    enabled = true
    fmt.Println(host, port, enabled)

    # Explicit typed declaration with initializer
    define_var :count, :int32, 100
    big = int64(count) * 1000
    fmt.Println(big)

    # Local const
    define_const :greeting, "hi"
    fmt.Println(greeting, PI, STATUS_ACTIVE, STATUS_INACTIVE)

    fmt.Println(packageLevel)

    # Shadowing in a bare block
    shadow = "outer"
    begin
      shadow = "inner"
      fmt.Println(shadow)
    end
    fmt.Println(shadow)

    # Swap
    swap1, swap2 = "first", "second"
    swap1, swap2 = swap2, swap1
    fmt.Println(swap1, swap2)

    # Blank identifier / multiple return
    _, kept = ignoreOne
    fmt.Println(kept)
  end

  # Unexported package-level function
  def ignoreOne # () -> (string, string)
    return "discarded", "kept"
  end
end
