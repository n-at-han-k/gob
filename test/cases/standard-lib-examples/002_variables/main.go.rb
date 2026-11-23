require "fmt"
module Main
  # Untyped constant; the compiler infers its type from usage.
  pi = 3.14159
  # Grouped constants share a single const block for readability.
  statusActive = "active"
  statusInactive = "inactive"
  # Package-level variable, accessible from anywhere in this package.
  packageLevel = "I live at package scope"
  def main
    # Variables declared without a value are set to their type's zero value.
    a = 0
    b = ""
    c = false
    d = 0.0
    fmt.Println("zero values:", a, b, c, d)
    # Explicit type with an initializer; the type could be omitted here.
    name = "Nathan"
    age = 30
    fmt.Println(name, age)
    # Short variable declaration; only valid inside functions.
    city = "Wellington"
    country = "New Zealand"
    fmt.Println(city, country)
    # Multiple assignment with mixed inferred types on one line.
    x, y, z = 1, 2.5, "three"
    fmt.Println(x, y, z)
    # Reassigning existing variables uses = instead of :=.
    x, y = 10, 20.5
    fmt.Println(x, y)
    # Grouped var block, handy for related configuration values.
    host = "localhost"
    port = 8080
    enabled = true
    fmt.Println(host, port, enabled)
    # Go requires an explicit conversion when mixing numeric types.
    count = 100
    big = int64(count) * 1000
    fmt.Println(big)
    # Local constants are scoped to the function they're declared in.
    greeting = "hi"
    fmt.Println(greeting, pi, statusActive, statusInactive)
    fmt.Println(packageLevel)
    # The inner block declares a new `shadow` that hides the outer one.
    shadow = "outer"
    shadow = "inner"
    fmt.Println(shadow)
    fmt.Println(shadow)
    # Tuple assignment swaps values without a temporary variable.
    swap1, swap2 = "first", "second"
    swap1, swap2 = swap2, swap1
    fmt.Println(swap1, swap2)
    # The blank identifier _ discards a return value we don't need.
    _, kept = ignoreOne()
    fmt.Println(kept)
  end

  private

    # Functions can return multiple values, common for (result, error) pairs.
    def self.ignoreOne
      return "discarded", "kept"
    end
end
