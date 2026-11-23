package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"encoding/json"
	"go/ast"
	"go/parser"
	"go/token"
	"reflect"
	"unsafe"
)

func pos(fset *token.FileSet, p token.Pos) any {
	if !p.IsValid() {
		return nil
	}
	pp := fset.Position(p)
	return map[string]any{
		"offset": pp.Offset,
		"line":   pp.Line,
		"column": pp.Column,
	}
}

func convertValue(fset *token.FileSet, v reflect.Value) any {
	if !v.IsValid() {
		return nil
	}

	t := v.Type()
	posType := reflect.TypeOf(token.NoPos)
	tokType := reflect.TypeOf(token.ILLEGAL)
	nodeType := reflect.TypeOf((*ast.Node)(nil)).Elem()

	switch {
	case t == posType:
		return pos(fset, v.Interface().(token.Pos))
	case t == tokType:
		tok := v.Interface().(token.Token)
		return tok.String()
	case t.Kind() == reflect.Bool:
		return v.Bool()
	case t.Kind() == reflect.String:
		return v.String()
	case t.Kind() == reflect.Int, t.Kind() == reflect.Int8, t.Kind() == reflect.Int16, t.Kind() == reflect.Int32, t.Kind() == reflect.Int64:
		return v.Int()
	case t.Kind() == reflect.Uint, t.Kind() == reflect.Uint8, t.Kind() == reflect.Uint16, t.Kind() == reflect.Uint32, t.Kind() == reflect.Uint64, t.Kind() == reflect.Uintptr:
		return v.Uint()
	case t.Kind() == reflect.Slice:
		if v.IsNil() {
			return []any{}
		}
		out := make([]any, v.Len())
		for i := 0; i < v.Len(); i++ {
			out[i] = convertValue(fset, v.Index(i))
		}
		return out
	case t.Kind() == reflect.Map:
		if v.IsNil() {
			return map[string]any{}
		}
		out := map[string]any{}
		iter := v.MapRange()
		for iter.Next() {
			k := fmtSprint(iter.Key())
			out[k] = convertValue(fset, iter.Value())
		}
		return out
	case t.Kind() == reflect.Interface:
		if v.IsNil() {
			return nil
		}
		return convertValue(fset, v.Elem())
	case t.Kind() == reflect.Pointer:
		if v.IsNil() {
			return nil
		}
		if t.Implements(nodeType) {
			return convertNode(fset, v.Interface().(ast.Node))
		}
		// *ast.Scope, *ast.Object etc - skip semantic/internal pointers
		return nil
	default:
		return nil
	}
}

func fmtSprint(v reflect.Value) string {
	if !v.IsValid() {
		return "<invalid>"
	}
	switch v.Kind() {
	case reflect.String:
		return v.String()
	default:
		b, err := json.Marshal(convertPlain(v))
		if err == nil {
			return string(b)
		}
		return "<key>"
	}
}

func convertPlain(v reflect.Value) any {
	if !v.IsValid() {
		return nil
	}
	switch v.Kind() {
	case reflect.String:
		return v.String()
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		return v.Int()
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64, reflect.Uintptr:
		return v.Uint()
	case reflect.Bool:
		return v.Bool()
	default:
		return v.String()
	}
}

func convertNode(fset *token.FileSet, n ast.Node) any {
	if n == nil {
		return nil
	}
	rv := reflect.ValueOf(n)
	if rv.Kind() == reflect.Pointer {
		rv = rv.Elem()
	}
	rt := rv.Type()
	fields := map[string]any{}
	for i := 0; i < rt.NumField(); i++ {
		f := rt.Field(i)
		if !f.IsExported() {
			continue
		}
		fields[f.Name] = convertValue(fset, rv.Field(i))
	}
	return map[string]any{
		"type":   rt.Name(),
		"fields": fields,
	}
}

//export ParseFileJSON
func ParseFileJSON(filename *C.char, src *C.char) *C.char {
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, C.GoString(filename), C.GoString(src), parser.ParseComments|parser.SkipObjectResolution)
	if err != nil && file == nil {
		b, _ := json.Marshal(map[string]any{"error": err.Error()})
		return C.CString(string(b))
	}
	out := map[string]any{"file": convertNode(fset, file)}
	if err != nil {
		out["error"] = err.Error()
	}
	b, _ := json.Marshal(out)
	return C.CString(string(b))
}

//export FreeString
func FreeString(str *C.char) {
	if str != nil {
		C.free(unsafe.Pointer(str))
	}
}

func main() {}
