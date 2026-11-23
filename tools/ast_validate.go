package main

import (
	"encoding/json"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"os/exec"
	"path/filepath"
	"reflect"
	"runtime"
	"sort"
	"strings"
)

type schemaField struct {
	Name     string `json:"name"`
	Type     string `json:"type"`
	Role     string `json:"role"`
	Optional bool   `json:"optional,omitempty"`
}

type schemaNode struct {
	Name     string        `json:"name"`
	Category string        `json:"category"`
	Fields   []schemaField `json:"fields"`
}

func repoRoot() (string, error) {
	_, file, _, ok := runtime.Caller(0)
	if !ok {
		return "", fmt.Errorf("runtime.Caller failed")
	}
	return filepath.Clean(filepath.Join(filepath.Dir(file), "..")), nil
}

func loadSchema(root string) ([]schemaNode, map[string]schemaNode, error) {
	cmd := exec.Command("go", "run", "./tools/ast.go")
	cmd.Dir = root
	out, err := cmd.Output()
	if err != nil {
		if ee, ok := err.(*exec.ExitError); ok {
			return nil, nil, fmt.Errorf("go run ./tools/ast.go failed: %v\n%s", err, ee.Stderr)
		}
		return nil, nil, fmt.Errorf("go run ./tools/ast.go failed: %v", err)
	}

	var nodes []schemaNode
	if err := json.Unmarshal(out, &nodes); err != nil {
		return nil, nil, fmt.Errorf("decode ast.go JSON: %v", err)
	}

	byName := make(map[string]schemaNode, len(nodes))
	for _, n := range nodes {
		byName[n.Name] = n
	}
	return nodes, byName, nil
}

var astTypes = func() map[string]reflect.Type {
	nodes := []ast.Node{
		(*ast.Comment)(nil),
		(*ast.CommentGroup)(nil),
		(*ast.Field)(nil),
		(*ast.FieldList)(nil),
		(*ast.BadExpr)(nil),
		(*ast.Ident)(nil),
		(*ast.Ellipsis)(nil),
		(*ast.BasicLit)(nil),
		(*ast.FuncLit)(nil),
		(*ast.CompositeLit)(nil),
		(*ast.ParenExpr)(nil),
		(*ast.SelectorExpr)(nil),
		(*ast.IndexExpr)(nil),
		(*ast.IndexListExpr)(nil),
		(*ast.SliceExpr)(nil),
		(*ast.TypeAssertExpr)(nil),
		(*ast.CallExpr)(nil),
		(*ast.StarExpr)(nil),
		(*ast.UnaryExpr)(nil),
		(*ast.BinaryExpr)(nil),
		(*ast.KeyValueExpr)(nil),
		(*ast.ArrayType)(nil),
		(*ast.StructType)(nil),
		(*ast.FuncType)(nil),
		(*ast.InterfaceType)(nil),
		(*ast.MapType)(nil),
		(*ast.ChanType)(nil),
		(*ast.BadStmt)(nil),
		(*ast.DeclStmt)(nil),
		(*ast.EmptyStmt)(nil),
		(*ast.LabeledStmt)(nil),
		(*ast.ExprStmt)(nil),
		(*ast.SendStmt)(nil),
		(*ast.IncDecStmt)(nil),
		(*ast.AssignStmt)(nil),
		(*ast.GoStmt)(nil),
		(*ast.DeferStmt)(nil),
		(*ast.ReturnStmt)(nil),
		(*ast.BranchStmt)(nil),
		(*ast.BlockStmt)(nil),
		(*ast.IfStmt)(nil),
		(*ast.CaseClause)(nil),
		(*ast.SwitchStmt)(nil),
		(*ast.TypeSwitchStmt)(nil),
		(*ast.CommClause)(nil),
		(*ast.SelectStmt)(nil),
		(*ast.ForStmt)(nil),
		(*ast.RangeStmt)(nil),
		(*ast.ImportSpec)(nil),
		(*ast.ValueSpec)(nil),
		(*ast.TypeSpec)(nil),
		(*ast.BadDecl)(nil),
		(*ast.GenDecl)(nil),
		(*ast.FuncDecl)(nil),
		(*ast.File)(nil),
		(*ast.Package)(nil),
	}
	m := make(map[string]reflect.Type, len(nodes))
	for _, n := range nodes {
		t := reflect.TypeOf(n).Elem()
		m[t.Name()] = t
	}
	return m
}()

func typeString(t reflect.Type) string {
	// Normalize to the form go/ast uses in source.
	s := t.String()
	s = strings.ReplaceAll(s, "ast.", "")
	s = strings.ReplaceAll(s, "token.", "token.")
	return s
}

func validateSchemaFields(schema []schemaNode) []string {
	var errs []string
	for _, n := range schema {
		rt, ok := astTypes[n.Name]
		if !ok {
			errs = append(errs, fmt.Sprintf("%s: no go/ast type registered", n.Name))
			continue
		}
		if rt.Kind() != reflect.Struct {
			errs = append(errs, fmt.Sprintf("%s: go/ast type is %s, want struct", n.Name, rt.Kind()))
			continue
		}

		seen := map[string]bool{}
		for _, f := range n.Fields {
			seen[f.Name] = true
			sf, ok := rt.FieldByName(f.Name)
			if !ok {
				errs = append(errs, fmt.Sprintf("%s.%s: field missing in go/ast struct", n.Name, f.Name))
				continue
			}
			gotType := typeString(sf.Type)
			wantType := f.Type
			if gotType != wantType {
				errs = append(errs, fmt.Sprintf("%s.%s: type mismatch schema=%s ast=%s", n.Name, f.Name, wantType, gotType))
			}
			if roleErr := validateRole(n.Name, f, sf.Type); roleErr != "" {
				errs = append(errs, roleErr)
			}
		}

		for i := 0; i < rt.NumField(); i++ {
			sf := rt.Field(i)
			if !sf.IsExported() {
				continue
			}
			if !seen[sf.Name] {
				errs = append(errs, fmt.Sprintf("%s.%s: field exists in go/ast but missing from schema (type=%s)", n.Name, sf.Name, typeString(sf.Type)))
			}
		}
	}
	return errs
}

func isNodeType(t reflect.Type) bool {
	nodeType := reflect.TypeOf((*ast.Node)(nil)).Elem()
	return t.Implements(nodeType) || (t.Kind() == reflect.Pointer && t.Implements(nodeType))
}

func isNodeSliceType(t reflect.Type) bool {
	return t.Kind() == reflect.Slice && isNodeType(t.Elem())
}

func validateRole(nodeName string, f schemaField, t reflect.Type) string {
	posType := reflect.TypeOf(token.NoPos)
	tokType := reflect.TypeOf(token.ILLEGAL)

	ok := true
	switch f.Role {
	case "pos":
		ok = t == posType
	case "token":
		ok = t == tokType
	case "bool":
		ok = t.Kind() == reflect.Bool
	case "string":
		ok = t.Kind() == reflect.String
	case "scalar":
		ok = t.Kind() == reflect.Int || t.Kind() == reflect.Int32 || t.Kind() == reflect.Int64 || t.Kind() == reflect.Uint || t.Kind() == reflect.Uintptr
	case "semantic":
		ok = t.Kind() == reflect.Pointer || t.Kind() == reflect.Interface || t.Kind() == reflect.Map
	case "map":
		ok = t.Kind() == reflect.Map
	case "child":
		ok = isNodeType(t) || t.Kind() == reflect.Interface
	case "children":
		ok = isNodeSliceType(t)
	default:
		return fmt.Sprintf("%s.%s: unknown role %q", nodeName, f.Name, f.Role)
	}
	if !ok {
		return fmt.Sprintf("%s.%s: role %q does not match go type %s", nodeName, f.Name, f.Role, typeString(t))
	}
	return ""
}

func validateValueRole(nodeName string, f schemaField, v reflect.Value) string {
	if !v.IsValid() {
		return fmt.Sprintf("%s.%s: invalid value", nodeName, f.Name)
	}
	t := v.Type()
	posType := reflect.TypeOf(token.NoPos)
	tokType := reflect.TypeOf(token.ILLEGAL)

	switch f.Role {
	case "pos":
		if t != posType {
			return fmt.Sprintf("%s.%s: want token.Pos got %s", nodeName, f.Name, typeString(t))
		}
	case "token":
		if t != tokType {
			return fmt.Sprintf("%s.%s: want token.Token got %s", nodeName, f.Name, typeString(t))
		}
	case "bool":
		if t.Kind() != reflect.Bool {
			return fmt.Sprintf("%s.%s: want bool got %s", nodeName, f.Name, typeString(t))
		}
	case "string":
		if t.Kind() != reflect.String {
			return fmt.Sprintf("%s.%s: want string got %s", nodeName, f.Name, typeString(t))
		}
	case "scalar":
		switch t.Kind() {
		case reflect.Int, reflect.Int32, reflect.Int64, reflect.Uint, reflect.Uintptr:
		default:
			return fmt.Sprintf("%s.%s: want scalar got %s", nodeName, f.Name, typeString(t))
		}
	case "semantic", "map":
		// semantic/map fields are not syntax children; just ensure no panic and type family is sane.
		switch t.Kind() {
		case reflect.Map, reflect.Pointer, reflect.Interface, reflect.Slice:
		default:
			return fmt.Sprintf("%s.%s: want semantic/map got %s", nodeName, f.Name, typeString(t))
		}
	case "child":
		if v.Kind() == reflect.Interface || v.Kind() == reflect.Pointer {
			if v.IsNil() {
				return ""
			}
			if !v.Type().Implements(reflect.TypeOf((*ast.Node)(nil)).Elem()) {
				// some interface fields may carry non-node, but schema says child; flag it
				return fmt.Sprintf("%s.%s: want node child got %s", nodeName, f.Name, v.Elem().Type().String())
			}
		} else {
			return fmt.Sprintf("%s.%s: want child node got %s", nodeName, f.Name, typeString(t))
		}
	case "children":
		if t.Kind() != reflect.Slice {
			return fmt.Sprintf("%s.%s: want slice got %s", nodeName, f.Name, typeString(t))
		}
		for i := 0; i < v.Len(); i++ {
			el := v.Index(i)
			if el.Kind() == reflect.Interface || el.Kind() == reflect.Pointer {
				if el.IsNil() {
					continue
				}
				if !el.Type().Implements(reflect.TypeOf((*ast.Node)(nil)).Elem()) {
					return fmt.Sprintf("%s.%s[%d]: want node child got %s", nodeName, f.Name, i, el.Elem().Type().String())
				}
			}
		}
	default:
		return fmt.Sprintf("%s.%s: unknown role %q", nodeName, f.Name, f.Role)
	}
	return ""
}

func main() {
	root, err := repoRoot()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	schema, byName, err := loadSchema(root)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var fieldDefErrors []string
	fieldDefErrors = append(fieldDefErrors, validateSchemaFields(schema)...)
	for _, e := range fieldDefErrors {
		fmt.Fprintln(os.Stderr, "schema:", e)
	}

	srcRoot := filepath.Join(root, "refs", "go", "src")
	fset := token.NewFileSet()

	var parseErrors, unexpected, fieldValueErrors, files, nodesSeen int
	counts := map[string]int{}

	err = filepath.WalkDir(srcRoot, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			if d.Name() == "testdata" {
				return filepath.SkipDir
			}
			return nil
		}
		if !strings.HasSuffix(path, ".go") {
			return nil
		}

		files++
		file, parseErr := parser.ParseFile(fset, path, nil, parser.ParseComments|parser.SkipObjectResolution)
		if parseErr != nil {
			fmt.Fprintf(os.Stderr, "parse error: %s: %v\n", path, parseErr)
			parseErrors++
		}
		if file == nil {
			return nil
		}

		ast.Inspect(file, func(n ast.Node) bool {
			if n == nil {
				return true
			}
			nodesSeen++
			rv := reflect.ValueOf(n)
			if rv.Kind() == reflect.Pointer {
				rv = rv.Elem()
			}
			name := rv.Type().Name()
			counts[name]++
			sn, ok := byName[name]
			if !ok {
				pos := fset.Position(n.Pos())
				fmt.Fprintf(os.Stderr, "unexpected node type %s at %s\n", name, pos)
				unexpected++
				return true
			}

			for _, f := range sn.Fields {
				fv := rv.FieldByName(f.Name)
				if !fv.IsValid() {
					pos := fset.Position(n.Pos())
					fmt.Fprintf(os.Stderr, "field missing at runtime %s.%s at %s\n", name, f.Name, pos)
					fieldValueErrors++
					continue
				}
				if msg := validateValueRole(name, f, fv); msg != "" {
					pos := fset.Position(n.Pos())
					fmt.Fprintf(os.Stderr, "field value error: %s at %s: %s\n", name, pos, msg)
					fieldValueErrors++
				}
			}
			return true
		})
		return nil
	})
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fmt.Printf("files=%d nodes=%d parse_errors=%d unexpected=%d schema_field_errors=%d field_value_errors=%d\n", files, nodesSeen, parseErrors, unexpected, len(fieldDefErrors), fieldValueErrors)

	type countEntry struct {
		Name  string
		Count int
	}
	var entries []countEntry
	for name, count := range counts {
		entries = append(entries, countEntry{Name: name, Count: count})
	}
	sort.Slice(entries, func(i, j int) bool {
		if entries[i].Count != entries[j].Count {
			return entries[i].Count > entries[j].Count
		}
		return entries[i].Name < entries[j].Name
	})
	for _, e := range entries {
		fmt.Printf("%s %d\n", e.Name, e.Count)
	}

	if parseErrors > 0 || unexpected > 0 || len(fieldDefErrors) > 0 || fieldValueErrors > 0 {
		os.Exit(1)
	}
}
