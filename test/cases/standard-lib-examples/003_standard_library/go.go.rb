# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/ast — Package ast declares the types used to represent syntax trees for Go packages.
require "go/ast"
# https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
require "go/parser"
# https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
require "go/token"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # The go/* packages let Go programs analyze Go source code.
    def self.runGoTools
      src =
        "package p\nfunc Add(a, b int) int { return a + b }\nfunc Sub(a, b int) int { return a - b }\n"

      fset = token.NewFileSet()
      file, err = parser.ParseFile(fset, "example.go", src, 0)

      if err != nil
        log.Fatal(err)
      end

      # Walk the AST and print every top-level function name.
      ast.Inspect(
        file,
        lambda do |n|
          fn, ok = n

          if ok
            pos = fset.Position(fn.Pos())
            fmt.Printf("func %s at %s\n", fn.Name.Name, pos)
          end

          return true
        end
      )
    end
end
