# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # The testing package is exercised from *_test.go files, not from a
    # regular main. Create a file like math_test.go with functions such as:
    #
    # func TestAdd(t *testing.T)       — unit tests
    # func BenchmarkAdd(b *testing.B)  — benchmarks
    # func ExampleAdd()                — verified example output
    #
    # then run `go test ./...`.
    def self.runTesting
      fmt.Println("testing is used via *_test.go files with `go test`")
    end
end
