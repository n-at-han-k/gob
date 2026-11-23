package main

import (
	"fmt"       // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/ast"    // https://pkg.go.dev/go/ast — Package ast declares the types used to represent syntax trees for Go packages.
	"go/parser" // https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
	"go/token"  // https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
	"log"       // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// ast is Go's syntax-tree representation. Every declaration, statement
// and expression in a parsed file is a node you can walk or rewrite.
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

	// Classify every top-level declaration.
	for _, decl := range file.Decls {
		switch d := decl.(type) {
		case *ast.FuncDecl:
			fmt.Printf("func %s at %s\n", d.Name.Name, fset.Position(d.Pos()))
		case *ast.GenDecl:
			fmt.Printf("%s at %s\n", d.Tok, fset.Position(d.Pos()))
		}
	}
}
