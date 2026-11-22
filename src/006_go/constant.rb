# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/constant — Package constant implements Values representing untyped Go constants and their corresponding operations.
require "go/constant"
# https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
require "go/token"
module Main
  private

    # constant models Go's untyped constants — arbitrary-precision values
    # that don't overflow until they're assigned to a typed variable.
    def self.runConstant
      # 1<<100 fits fine as an untyped int constant.
      big = constant.Shift(constant.MakeInt64(1), token.SHL, 100)
      fmt.Println("1 << 100 =", big)

      # Mixed-kind arithmetic promotes just like the language spec.
      sum =
        constant.BinaryOp(constant.MakeFloat64(1.5), token.ADD, constant.MakeInt64(2))

      fmt.Println("1.5 + 2 =", sum, "(kind:", sum.Kind(), ")")
      # Comparisons return a bool.
      fmt.Println("1<<100 > 1e30?", constant.Compare(big, token.GTR, constant.MakeFloat64(1e30)))
    end
end
