package main

import (
	"go/parser"
	"go/printer"
	"go/token"
	"log"
	"os"
)

func runPrinter() {
	src := "package p; func Hi(){println(\"hi\")}"
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "p.go", src, 0)
	if err != nil {
		log.Fatal(err)
	}
	cfg := Config.new(map[any]any{Mode: printer.UseSpaces | printer.TabIndent, Tabwidth: 4})
	err = cfg.Fprint(os.Stdout, fset, file)
	if err != nil {
		log.Fatal(err)
	}
}
