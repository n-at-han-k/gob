package main

import (
	"fmt"      // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/build" // https://pkg.go.dev/go/build — Package build gathers information about Go packages.
	"log"      // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// build asks the toolchain about a package the way `go build` would —
// import path, source files, imports, build tags for the current arch.
func runBuild() {
	pkg, err := build.Default.Import("fmt", "", 0)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("import path:", pkg.ImportPath)
	fmt.Println("directory:  ", pkg.Dir)
	fmt.Println("go files:   ", pkg.GoFiles)
	fmt.Println("imports:    ", pkg.Imports)
}
