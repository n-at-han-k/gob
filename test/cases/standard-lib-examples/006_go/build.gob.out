package main

import (
	"fmt"
	"go/build"
	"log"
)

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
