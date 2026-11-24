require "fmt"
require "go/ast"
require "go/doc"
require "go/parser"
require "go/token"
require "log"

module Main

    # ()
    def runDoc
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
