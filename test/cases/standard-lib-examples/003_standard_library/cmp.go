package main

import (
	"cmp" // https://pkg.go.dev/cmp — Package cmp provides types and functions related to comparing ordered values.
	"fmt" // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

func runCmp() {
	// Compare returns -1, 0, or 1 for ordered types.
	fmt.Println(cmp.Compare(1, 2))     // -1
	fmt.Println(cmp.Compare(3, 3))     // 0
	fmt.Println(cmp.Compare("b", "a")) // 1

	// Less returns a boolean; handy as a sort comparator.
	fmt.Println(cmp.Less(1.5, 2.0)) // true

	// Or returns the first non-zero value — useful for defaults.
	name := cmp.Or("", "", "fallback")
	fmt.Println(name)
}
