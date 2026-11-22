package main

import (
	"fmt"
	"go/scanner"
	"go/token"
)

func runScanner() {
	src := "x := 1 + 2 // trailing comment".bytes
	fset := token.NewFileSet()
	file := fset.AddFile("snippet.go", fset.Base(), len(src))
	s := nil
	s.Init(file, src, nil, scanner.ScanComments)
	for {
		pos, tok, lit := s.Scan()
		if tok == token.EOF {
			break
		}
		fmt.Printf("%s\t%s\t%q\n", fset.Position(pos), tok, lit)
	}
}
