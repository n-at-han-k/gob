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

    # ast is Go's syntax-tree representation. Every declaration, statement
    # and expression in a parsed file is a node you can walk or rewrite.
    def self.runAST
      src =
        "package p\n// Add returns a+b.\nfunc Add(a, b int) int { return a + b }\nvar Answer = 42\n"

      fset = token.NewFileSet()
      file, err = parser.ParseFile(fset, "example.go", src, parser.ParseComments)

      if err != nil
        log.Fatal(err)
      end

      # Classify every top-level declaration.
      file.Decls.each do |_, decl|
        case decl
        when ast.FuncDecl
          fmt.Printf("func %s at %s\n", d.Name.Name, fset.Position(d.Pos()))
        when ast.GenDecl
          fmt.Printf("%s at %s\n", d.Tok, fset.Position(d.Pos()))
        end
      end
    end
end
