# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/version — Package version provides operations on Go versions in Go toolchain name syntax.
require "go/version"
module Main
  private

    # version knows how to compare toolchain strings like "go1.21" and
    # "go1.22rc2" — useful when your tool needs to gate on the Go release.
    def self.runVersion
      vs = %w[go1.20 go1.21.0 go1.22rc2 go1.23.4-custom notaversion]

      vs.each do |_, v|
        fmt.Printf("%-20s valid=%v lang=%s\n", v, version.IsValid(v), version.Lang(v))
      end

      fmt.Println("go1.21 <  go1.22:", version.Compare("go1.21", "go1.22") < 0)
      fmt.Println("go1.22 >= go1.22rc2:", version.Compare("go1.22", "go1.22rc2") >= 0)
    end
end
