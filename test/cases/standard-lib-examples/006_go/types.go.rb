require "fmt"
require "go/ast"
require "go/importer"
require "go/parser"
require "go/token"
require "go/types"
require "log"

module Main

    # ()
    def runTypes
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
