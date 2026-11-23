package main

import (
	"encoding/json"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

type Node struct {
	Name     string  `json:"name"`
	Category string  `json:"category"` // expr, stmt, decl, spec, node
	Fields   []Field `json:"fields,omitempty"`
}

type Field struct {
	Name     string `json:"name"`
	Type     string `json:"type"`
	Role     string `json:"role"` // child, children, pos, token, bool, string, scalar, semantic, map
	Optional bool   `json:"optional,omitempty"`
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

	category := map[string]string{}
	hasPos, hasEnd := map[string]bool{}, map[string]bool{}
	for _, pkg := range pkgs {
		ast.Inspect(pkg, func(n ast.Node) bool {
			fn, ok := n.(*ast.FuncDecl)
			if !ok || fn.Recv == nil || len(fn.Recv.List) != 1 {
				return true
			}
			recv := recvName(fn.Recv.List[0].Type)
			switch fn.Name.Name {
			case "exprNode":
				category[recv] = "expr"
			case "stmtNode":
				category[recv] = "stmt"
			case "declNode":
				category[recv] = "decl"
			case "specNode":
				category[recv] = "spec"
			case "Pos":
				hasPos[recv] = true
			case "End":
				hasEnd[recv] = true
			}
			return true
		})
	}

	var out []Node
	for _, pkg := range pkgs {
		names := make([]string, 0, len(pkg.Files))
		for name := range pkg.Files {
			names = append(names, name)
		}
		sort.Strings(names)
		for _, name := range names {
			file := pkg.Files[name]
			for _, decl := range file.Decls {
				gd, ok := decl.(*ast.GenDecl)
				if !ok || gd.Tok != token.TYPE {
					continue
				}
				for _, spec := range gd.Specs {
					ts := spec.(*ast.TypeSpec)
					st, ok := ts.Type.(*ast.StructType)
					if !ok || !hasPos[ts.Name.Name] || !hasEnd[ts.Name.Name] {
						continue
					}
					nodeName := ts.Name.Name
					cat := category[nodeName]
					if cat == "" {
						switch nodeName {
						case "Comment", "CommentGroup", "Field", "FieldList", "File", "Package":
							cat = "node"
						default:
							continue // non-syntax Node impl (Directive, Object, etc.)
						}
					}
					node := Node{Name: nodeName, Category: cat}
					for _, f := range st.Fields.List {
						ft := text(f.Type)
						role, optional := classify(ft)
						for _, n := range f.Names {
							node.Fields = append(node.Fields, Field{
								Name: n.Name, Type: ft, Role: role, Optional: optional,
							})
						}
					}
					out = append(out, node)
				}
			}
		}
	}

	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	if err := enc.Encode(out); err != nil {
		panic(err)
	}
}

func recvName(expr ast.Expr) string {
	if s, ok := expr.(*ast.StarExpr); ok {
		expr = s.X
	}
	id, _ := expr.(*ast.Ident)
	if id == nil {
		return ""
	}
	return id.Name
}

func classify(t string) (role string, optional bool) {
	switch {
	case t == "token.Pos":
		return "pos", false
	case t == "token.Token":
		return "token", false
	case t == "bool":
		return "bool", false
	case t == "string":
		return "string", false
	case t == "int" || t == "ChanDir":
		return "scalar", false
	case t == "*Scope" || t == "*Object":
		return "semantic", true // deprecated/semantic metadata, not syntax children
	case strings.HasPrefix(t, "map["):
		return "map", true
	case strings.HasPrefix(t, "[]"):
		return "children", true
	case strings.HasPrefix(t, "*"), t == "Expr" || t == "Stmt" || t == "Decl" || t == "Spec" || t == "Node" || t == "any":
		return "child", true
	default:
		return "scalar", false
	}
}
