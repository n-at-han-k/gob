package main

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"log"
)

func runGoTools() {
	src := `package p
func Add(a, b int) int { return a + b }
func Sub(a, b int) int { return a - b }
`
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "example.go", src, 0)
	if err != nil {
		log.Fatal(err)
	}
	ast.Inspect(file, func(n ast.Node) bool {
		fn, ok := n.(*ast.FuncDecl)
		if ok {
			pos := fset.Position(fn.Pos())
			fmt.Printf("func %s at %s\n", fn.Name.Name, pos)
		}
		return true
	})
}
