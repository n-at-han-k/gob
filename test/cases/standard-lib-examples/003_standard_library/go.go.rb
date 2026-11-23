require "fmt"
require "go/ast"
require "go/parser"
require "go/token"
require "log"
module Main
  private

    def self.runGoTools
      src =
        "package p\nfunc Add(a, b int) int { return a + b }\nfunc Sub(a, b int) int { return a - b }\n"

      fset = token.NewFileSet()
      file, err = parser.ParseFile(fset, "example.go", src, 0)

      if err != nil
        log.Fatal(err)
      end

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
