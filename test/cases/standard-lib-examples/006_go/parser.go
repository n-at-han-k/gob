package main

import (
	"fmt"       // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/parser" // https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
	"go/token"  // https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
	"log"       // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// parser turns Go source (a file, a directory, or a single expression)
// into an AST. Errors are reported via a *token.FileSet, so line/column
// positions stay meaningful across many files.
func runParser() {
	// Parse a standalone expression rather than a whole file.
	expr, err := parser.ParseExpr("1 + 2*3")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("expression AST: %#v\n\n", expr)

	// Parse a small file and print each import.
	src := `package p
import (
	"fmt"
	"io"
)
`
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "p.go", src, parser.ImportsOnly)
	if err != nil {
		log.Fatal(err)
	}
	for _, imp := range file.Imports {
		fmt.Println("import", imp.Path.Value)
	}
}
