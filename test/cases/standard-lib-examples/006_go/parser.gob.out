package main

import (
	"fmt"
	"go/parser"
	"go/token"
	"log"
)

func runParser() {
	expr, err := parser.ParseExpr("1 + 2*3")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("expression AST: %#v\n\n", expr)
	src := "package p\nimport (\n\t\"fmt\"\n\t\"io\"\n)\n"
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "p.go", src, parser.ImportsOnly)
	if err != nil {
		log.Fatal(err)
	}
	for _, imp := range file.Imports {
		fmt.Println("import", imp.Path.Value)
	}
}
