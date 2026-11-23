package main

import (
	_ "embed" // https://pkg.go.dev/embed — Package embed provides access to files embedded in the running Go program.
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// //go:embed reads a file at build time into the variable.
// The greeting.txt file is created alongside this main.go.
//
//go:embed greeting.txt
var greeting string

func runEmbed() {
	fmt.Print(greeting)
}
