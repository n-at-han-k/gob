package main

import (
	"fmt"       // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/ast"    // https://pkg.go.dev/go/ast — Package ast declares the types used to represent syntax trees for Go packages.
	"go/doc"    // https://pkg.go.dev/go/doc — Package doc extracts source code documentation from a Go AST.
	"go/parser" // https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
	"go/token"  // https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
	"log"       // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// doc turns a parsed package into the structure godoc renders:
// the package synopsis plus a doc comment for each exported symbol.
func runDoc() {
	src := `// Package math2 does a little arithmetic.
package math2

// Add returns the sum of a and b.
func Add(a, b int) int { return a + b }

// Sub returns a minus b.
func Sub(a, b int) int { return a - b }
`
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "math2.go", src, parser.ParseComments)
	if err != nil {
		log.Fatal(err)
	}

	p, err := doc.NewFromFiles(fset, []*ast.File{file}, "example.com/math2")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("package:", p.Name)
	fmt.Println("synopsis:", doc.Synopsis(p.Doc))
	for _, f := range p.Funcs {
		fmt.Printf("  func %s: %s", f.Name, f.Doc)
	}
}
