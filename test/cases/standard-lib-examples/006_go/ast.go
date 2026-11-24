package main

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"log"
)

func runAST() {
	src := `package p
// Add returns a+b.
func Add(a, b int) int { return a + b }
var Answer = 42
`
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "example.go", src, parser.ParseComments)
	if err != nil {
		log.Fatal(err)
	}

	for _, decl := range file.Decls {
		switch d := decl.(type) {
		case *ast.FuncDecl:
			fmt.Printf("func %s at %s\n", d.Name.Name, fset.Position(d.Pos()))
		case *ast.GenDecl:
			fmt.Printf("%s at %s\n", d.Tok, fset.Position(d.Pos()))
		}
	}
}
