package main

import (
	"fmt"
	"go/ast"
	"go/doc"
	"go/parser"
	"go/token"
	"log"
)

func runDoc() {
	src := "// Package math2 does a little arithmetic.\npackage math2\n\n// Add returns the sum of a and b.\nfunc Add(a, b int) int { return a + b }\n\n// Sub returns a minus b.\nfunc Sub(a, b int) int { return a - b }\n"
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "math2.go", src, parser.ParseComments)
	if err != nil {
		log.Fatal(err)
	}
	p, err := doc.NewFromFiles(fset, []any{file}, "example.com/math2")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("package:", p.Name)
	fmt.Println("synopsis:", doc.Synopsis(p.Doc))
	for _, f := range p.Funcs {
		fmt.Printf("  func %s: %s", f.Name, f.Doc)
	}
}
