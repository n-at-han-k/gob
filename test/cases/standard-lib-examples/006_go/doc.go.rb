# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/ast — Package ast declares the types used to represent syntax trees for Go packages.
require "go/ast"
# https://pkg.go.dev/go/doc — Package doc extracts source code documentation from a Go AST.
require "go/doc"
# https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
require "go/parser"
# https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
require "go/token"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # doc turns a parsed package into the structure godoc renders:
    # the package synopsis plus a doc comment for each exported symbol.
    def self.runDoc
      src =
        "// Package math2 does a little arithmetic.\npackage math2\n\n// Add returns the sum of a and b.\nfunc Add(a, b int) int { return a + b }\n\n// Sub returns a minus b.\nfunc Sub(a, b int) int { return a - b }\n"

      fset = token.NewFileSet()
      file, err = parser.ParseFile(fset, "math2.go", src, parser.ParseComments)

      if err != nil
        log.Fatal(err)
      end

      p, err = doc.NewFromFiles(fset, [file], "example.com/math2")

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("package:", p.Name)
      fmt.Println("synopsis:", doc.Synopsis(p.Doc))
      p.Funcs.each { |_, f| fmt.Printf("  func %s: %s", f.Name, f.Doc) }
    end
end
