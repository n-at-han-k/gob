package main

import (
	"go/parser"  // https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
	"go/printer" // https://pkg.go.dev/go/printer — Package printer implements printing of AST nodes.
	"go/token"   // https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
	"log"        // https://pkg.go.dev/log — Package log implements a simple logging package.
	"os"         // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
)

// printer walks an AST and writes it out as source. Pair it with
// parser to build refactoring tools: parse → mutate → print.
func runPrinter() {
	src := `package p; func Hi(){println("hi")}`

	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "p.go", src, 0)
	if err != nil {
		log.Fatal(err)
	}

	cfg := printer.Config{Mode: printer.UseSpaces | printer.TabIndent, Tabwidth: 4}
	if err := cfg.Fprint(os.Stdout, fset, file); err != nil {
		log.Fatal(err)
	}
}
