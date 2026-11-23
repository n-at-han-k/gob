package main

import (
	"fmt"         // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/ast"      // https://pkg.go.dev/go/ast — Package ast declares the types used to represent syntax trees for Go packages.
	"go/importer" // https://pkg.go.dev/go/importer — Package importer provides access to export data importers.
	"go/parser"   // https://pkg.go.dev/go/parser — Package parser implements a parser for Go source files.
	"go/token"    // https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
	"go/types"    // https://pkg.go.dev/go/types — Package types declares the data types and implements the algorithms for type-checking of Go packages.
	"log"         // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// types is Go's actual type-checker. Feed it an AST plus an importer
// and it will resolve every identifier, catch type errors and tell you
// the inferred type of any expression.
func runTypes() {
	src := `package p
import "fmt"
func Greet(name string) { fmt.Println("hi", name) }
var Answer = 21 * 2
`
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "p.go", src, 0)
	if err != nil {
		log.Fatal(err)
	}

	conf := types.Config{Importer: importer.Default()}
	info := &types.Info{
		Defs:  map[*ast.Ident]types.Object{},
		Types: map[ast.Expr]types.TypeAndValue{},
	}
	pkg, err := conf.Check("p", fset, []*ast.File{file}, info)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("package:", pkg.Name())
	for id, obj := range info.Defs {
		if obj == nil {
			continue
		}
		fmt.Printf("  %s :: %s\n", id.Name, obj.Type())
	}
}
