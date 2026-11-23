package main

import (
	"fmt"    // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"iter"   // https://pkg.go.dev/iter — Package iter provides basic definitions and operations related to iterators over sequences.
	"slices" // https://pkg.go.dev/slices — Package slices defines various functions useful with slices of any type.
)

// countdown returns an iter.Seq[int] — a pull-style iterator you can
// consume with for/range (Go 1.23+).
func countdown(from int) iter.Seq[int] {
	return func(yield func(int) bool) {
		for i := from; i >= 0; i-- {
			if !yield(i) {
				return
			}
		}
	}
}

func runIter() {
	for n := range countdown(3) {
		fmt.Println(n)
	}

	// slices.All returns an iter.Seq2 of (index, value) pairs.
	for i, v := range slices.All([]string{"a", "b", "c"}) {
		fmt.Println(i, v)
	}
}
