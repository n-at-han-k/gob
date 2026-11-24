require "go/parser"
require "go/printer"
require "go/token"
require "log"
require "os"

module Main

    # ()
    def runPrinter
      src = "package p; func Hi(){println(\"hi\")}"
      fset = token.NewFileSet()
      file, err = parser.ParseFile(fset, "p.go", src, 0)

      if err != nil
        log.Fatal(err)
      end

      cfg = Config.new(Mode: printer.UseSpaces | printer.TabIndent, Tabwidth: 4)
      err = cfg.Fprint(os.Stdout, fset, file)

      if err != nil
        log.Fatal(err)
      end
    end
end
