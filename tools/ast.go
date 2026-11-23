package main

import (
	"encoding/json"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
)

type Decl struct {
	Name    string   `json:"name"`
	Kind    string   `json:"kind"`
	Fields  []Field  `json:"fields,omitempty"`
	Methods []string `json:"methods,omitempty"`
	Markers []string `json:"markers,omitempty"`
}

type Field struct {
	Name string `json:"name"`
	Type string `json:"type"`
}

func main() {
	dir := "refs/go/src/go/ast"
	if len(os.Args) > 1 {
		dir = os.Args[1]
	}

	fset := token.NewFileSet()

	pkgs, err := parser.ParseDir(fset, dir, nil, 0)
	if err != nil {
		panic(err)
	}

	src := map[string][]byte{}
	for _, pkg := range pkgs {
		for name := range pkg.Files {
			b, err := os.ReadFile(name)
			if err != nil {
				panic(err)
			}
			src[filepath.Base(name)] = b
		}
	}

	text := func(n ast.Node) string {
		p, e := fset.Position(n.Pos()), fset.Position(n.End())
		return string(src[filepath.Base(p.Filename)][p.Offset:e.Offset])
	}

	decls := map[string]*Decl{}
	var order []string

	for _, pkg := range pkgs {
		ast.Inspect(pkg, func(n ast.Node) bool {
			spec, ok := n.(*ast.TypeSpec)
			if !ok {
				return true
			}

			decl := &Decl{Name: spec.Name.Name, Kind: text(spec.Type)}

			switch t := spec.Type.(type) {
			case *ast.StructType:
				decl.Kind = "struct"
				for _, f := range t.Fields.List {
					if f.Names == nil {
						decl.Fields = append(decl.Fields, Field{text(f.Type), text(f.Type)})
					}
					for _, name := range f.Names {
						decl.Fields = append(decl.Fields, Field{name.Name, text(f.Type)})
					}
				}
			case *ast.InterfaceType:
				decl.Kind = "interface"
				for _, m := range t.Methods.List {
					for _, name := range m.Names {
						decl.Methods = append(decl.Methods, name.Name)
					}
				}
			}

			decls[decl.Name] = decl
			order = append(order, decl.Name)
			return false
		})
	}

	for _, pkg := range pkgs {
		ast.Inspect(pkg, func(n ast.Node) bool {
			fn, ok := n.(*ast.FuncDecl)
			if !ok {
				return true
			}
			if fn.Recv == nil || len(fn.Recv.List) != 1 {
				return false
			}

			recv := fn.Recv.List[0].Type
			if star, ok := recv.(*ast.StarExpr); ok {
				recv = star.X
			}
			if id, ok := recv.(*ast.Ident); ok {
				if decl, ok := decls[id.Name]; ok {
					decl.Markers = append(decl.Markers, fn.Name.Name)
				}
			}
			return false
		})
	}

	out := make([]*Decl, 0, len(order))
	for _, name := range order {
		out = append(out, decls[name])
	}

	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	if err := enc.Encode(out); err != nil {
		panic(err)
	}
}
