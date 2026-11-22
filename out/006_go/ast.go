package main

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"log"
)

func runAST() {
	src := "package p\n// Add returns a+b.\nfunc Add(a, b int) int { return a + b }\nvar Answer = 42\n"
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "example.go", src, parser.ParseComments)
	if err != nil {
		log.Fatal(err)
	}
	for _, decl := range file.Decls {
		switch decl {
		case ast.FuncDecl:
			fmt.Printf("func %s at %s\n", d.Name.Name, fset.Position(d.Pos()))
		case ast.GenDecl:
			fmt.Printf("%s at %s\n", d.Tok, fset.Position(d.Pos()))
		}
	}
}
