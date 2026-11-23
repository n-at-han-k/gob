package main

import (
	"fmt"    // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"slices" // https://pkg.go.dev/slices — Package slices defines various functions useful with slices of any type.
)

func runSlices() {
	s := []int{3, 1, 4, 1, 5, 9, 2, 6}

	// Sort in place, then binary-search.
	slices.Sort(s)
	fmt.Println("sorted:", s)
	fmt.Println("Contains 5:", slices.Contains(s, 5))
	idx, found := slices.BinarySearch(s, 5)
	fmt.Println("BinarySearch 5:", idx, found)

	// Aggregations.
	fmt.Println("Min:", slices.Min(s), "Max:", slices.Max(s))

	// Reverse and Clone.
	cp := slices.Clone(s)
	slices.Reverse(cp)
	fmt.Println("reversed clone:", cp)

	// DeleteFunc removes elements matching a predicate.
	odd := slices.DeleteFunc(slices.Clone(s), func(v int) bool { return v%2 == 0 })
	fmt.Println("odd only:", odd)
}
