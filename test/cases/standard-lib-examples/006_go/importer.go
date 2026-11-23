package main

import (
	"fmt"         // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/importer" // https://pkg.go.dev/go/importer — Package importer provides access to export data importers.
	"log"         // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// importer bridges go/types to the installed toolchain: given an import
// path, hand back a *types.Package with everything the type-checker
// needs to resolve identifiers from that package.
func runImporter() {
	pkg, err := importer.Default().Import("fmt")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("package:", pkg.Path())
	fmt.Println("name:   ", pkg.Name())
	fmt.Println("first 5 exported names:")
	for i, name := range pkg.Scope().Names() {
		if i == 5 {
			break
		}
		fmt.Println("  ", name)
	}
}
