package main

import (
	"fmt"       // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/format" // https://pkg.go.dev/go/format — Package format implements standard formatting of Go source.
	"log"       // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// format is the library behind `gofmt`: take any Go source and return
// the canonical, formatted version.
func runFormat() {
	src := []byte(`package p
func   Add(a,b int)int{return a+b}
`)

	pretty, err := format.Source(src)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("---before---")
	fmt.Print(string(src))
	fmt.Println("---after----")
	fmt.Print(string(pretty))
}
