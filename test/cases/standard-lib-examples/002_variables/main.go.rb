require "fmt"
module Main
  pi = 3.14159
  statusActive = "active"
  statusInactive = "inactive"
  packageLevel = "I live at package scope"
  def main
    a = 0
    b = ""
    c = false
    d = 0.0
    fmt.Println("zero values:", a, b, c, d)
    name = "Nathan"
    age = 30
    fmt.Println(name, age)
    city = "Wellington"
    country = "New Zealand"
    fmt.Println(city, country)
    x, y, z = 1, 2.5, "three"
    fmt.Println(x, y, z)
    x, y = 10, 20.5
    fmt.Println(x, y)
    host = "localhost"
    port = 8080
    enabled = true
    fmt.Println(host, port, enabled)
    count = 100
    big = int64(count) * 1000
    fmt.Println(big)
    greeting = "hi"
    fmt.Println(greeting, pi, statusActive, statusInactive)
    fmt.Println(packageLevel)
    shadow = "outer"
    shadow = "inner"
    fmt.Println(shadow)
    fmt.Println(shadow)
    swap1, swap2 = "first", "second"
    swap1, swap2 = swap2, swap1
    fmt.Println(swap1, swap2)
    _, kept = ignoreOne()
    fmt.Println(kept)
  end

  private

    def self.ignoreOne
      return "discarded", "kept"
    end
end
