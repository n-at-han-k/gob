require "fmt"
require "go/ast"
require "go/parser"
require "go/token"
require "log"
module Main
  private

    def self.runAST
      src =
        "package p\n// Add returns a+b.\nfunc Add(a, b int) int { return a + b }\nvar Answer = 42\n"

      fset = token.NewFileSet()
      file, err = parser.ParseFile(fset, "example.go", src, parser.ParseComments)

      if err != nil
        log.Fatal(err)
      end

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
