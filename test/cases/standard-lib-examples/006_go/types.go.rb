# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/ast — Package ast declares the types used to represent syntax trees for Go packages.
require "go/ast"
# https://pkg.go.dev/go/importer — Package importer provides access to export data importers.
require "go/importer"
# https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
require "go/parser"
# https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
require "go/token"
# https://pkg.go.dev/go/types — Package types declares the data types and implements the algorithms for type-checking of Go packages.
require "go/types"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # types is Go's actual type-checker. Feed it an AST plus an importer
    # and it will resolve every identifier, catch type errors and tell you
    # the inferred type of any expression.
    def self.runTypes
      src =
        "package p\nimport \"fmt\"\nfunc Greet(name string) { fmt.Println(\"hi\", name) }\nvar Answer = 21 * 2\n"

      fset = token.NewFileSet()
      file, err = parser.ParseFile(fset, "p.go", src, 0)

      if err != nil
        log.Fatal(err)
      end

      conf = Config.new(Importer: importer.Default())
      info = Info.new(Defs: {}, Types: {})
      pkg, err = conf.Check("p", fset, [file], info)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("package:", pkg.Name())

      info.Defs.each do |id, obj|
        if obj == nil
          next
        end

        fmt.Printf("  %s :: %s\n", id.Name, obj.Type())
      end
    end
end
