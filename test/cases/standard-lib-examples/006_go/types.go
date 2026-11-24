package main

import (
	"fmt"
	"go/ast"
	"go/importer"
	"go/parser"
	"go/token"
	"go/types"
	"log"
)

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
