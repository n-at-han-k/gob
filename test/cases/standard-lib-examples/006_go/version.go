package main

import (
	"fmt"        // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/version" // https://pkg.go.dev/go/version — Package version provides operations on Go versions in Go toolchain name syntax.
)

// version knows how to compare toolchain strings like "go1.21" and
// "go1.22rc2" — useful when your tool needs to gate on the Go release.
func runVersion() {
	vs := []string{"go1.20", "go1.21.0", "go1.22rc2", "go1.23.4-custom", "notaversion"}

	for _, v := range vs {
		fmt.Printf("%-20s valid=%v lang=%s\n", v, version.IsValid(v), version.Lang(v))
	}

	fmt.Println("go1.21 <  go1.22:", version.Compare("go1.21", "go1.22") < 0)
	fmt.Println("go1.22 >= go1.22rc2:", version.Compare("go1.22", "go1.22rc2") >= 0)
}
