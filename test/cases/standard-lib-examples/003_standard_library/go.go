package main

import (
	"fmt"       // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/ast"    // https://pkg.go.dev/go/ast — Package ast declares the types used to represent syntax trees for Go packages.
	"go/parser" // https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
	"go/token"  // https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
	"log"       // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// The go/* packages let Go programs analyze Go source code.
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

	// Walk the AST and print every top-level function name.
	ast.Inspect(file, func(n ast.Node) bool {
		if fn, ok := n.(*ast.FuncDecl); ok {
			pos := fset.Position(fn.Pos())
			fmt.Printf("func %s at %s\n", fn.Name.Name, pos)
		}
		return true
	})
}
