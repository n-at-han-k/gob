# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
require "go/parser"
# https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
require "go/token"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # parser turns Go source (a file, a directory, or a single expression)
    # into an AST. Errors are reported via a *token.FileSet, so line/column
    # positions stay meaningful across many files.
    def self.runParser
      # Parse a standalone expression rather than a whole file.
      expr, err = parser.ParseExpr("1 + 2*3")

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("expression AST: %#v\n\n", expr)
      # Parse a small file and print each import.
      src = "package p\nimport (\n\t\"fmt\"\n\t\"io\"\n)\n"
      fset = token.NewFileSet()
      file, err = parser.ParseFile(fset, "p.go", src, parser.ImportsOnly)

      if err != nil
        log.Fatal(err)
      end

      file.Imports.each { |_, imp| fmt.Println("import", imp.Path.Value) }
    end
end
