package main

import (
	"fmt"        // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/scanner" // https://pkg.go.dev/go/scanner — Package scanner implements a scanner for Go source text.
	"go/token"   // https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
)

// scanner is the lexer: it turns raw source bytes into a stream of
// (position, token, literal) triples. Below the parser, above the file.
func runScanner() {
	src := []byte(`x := 1 + 2 // trailing comment`)

	fset := token.NewFileSet()
	file := fset.AddFile("snippet.go", fset.Base(), len(src))

	var s scanner.Scanner
	s.Init(file, src, nil, scanner.ScanComments)

	for {
		pos, tok, lit := s.Scan()
		if tok == token.EOF {
			break
		}
		fmt.Printf("%s\t%s\t%q\n", fset.Position(pos), tok, lit)
	}
}
