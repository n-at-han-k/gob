# https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
require "go/parser"
# https://pkg.go.dev/go/printer — Package printer implements printing of AST nodes.
require "go/printer"
# https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
require "go/token"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
module Main
  private

    # printer walks an AST and writes it out as source. Pair it with
    # parser to build refactoring tools: parse → mutate → print.
    def self.runPrinter
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
