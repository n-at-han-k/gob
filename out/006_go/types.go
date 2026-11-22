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
	src := "package p\nimport \"fmt\"\nfunc Greet(name string) { fmt.Println(\"hi\", name) }\nvar Answer = 21 * 2\n"
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "p.go", src, 0)
	if err != nil {
		log.Fatal(err)
	}
	conf := Config.new(map[any]any{Importer: importer.Default()})
	info := Info.new(map[any]any{Defs: map[any]any{}, Types: map[any]any{}})
	pkg, err := conf.Check("p", fset, []any{file}, info)
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
