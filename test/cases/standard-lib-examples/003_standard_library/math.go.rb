# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/math — Package math provides basic constants and mathematical functions.
require "math"
module Main
  private

    def self.runMath
      fmt.Println("Pi:      ", math.Pi)
      fmt.Println("Sqrt(2): ", math.Sqrt(2))
      fmt.Println("Pow:     ", math.Pow(2, 10))
      fmt.Println("Log2(8): ", math.Log2(8))
      fmt.Println("Sin(π/2):", math.Sin(math.Pi / 2))
      fmt.Println("Abs(-5): ", math.Abs(-5))
      fmt.Println("Ceil:    ", math.Ceil(1.2))
      fmt.Println("Floor:   ", math.Floor(1.8))
      fmt.Println("Round:   ", math.Round(1.5))
      # Special floating-point values.
      fmt.Println("Inf > MaxFloat64:", math.IsInf(math.Inf(1), 1))
      fmt.Println("IsNaN(NaN):     ", math.IsNaN(math.NaN()))
    end
end
