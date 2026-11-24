require "fmt"
require "go/parser"
require "go/token"
require "log"

module Main

    # ()
    def runParser
      expr, err = parser.ParseExpr("1 + 2*3")

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("expression AST: %#v\n\n", expr)
      src = "package p\nimport (\n\t\"fmt\"\n\t\"io\"\n)\n"
      fset = token.NewFileSet()
      file, err = parser.ParseFile(fset, "p.go", src, parser.ImportsOnly)

      if err != nil
        log.Fatal(err)
      end

      file.Imports.each { |_, imp| fmt.Println("import", imp.Path.Value) }
    end
end
