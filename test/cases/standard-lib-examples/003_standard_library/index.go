package main

import (
	"fmt"               // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"index/suffixarray" // https://pkg.go.dev/index/suffixarray — Package suffixarray implements substring search in logarithmic time using a suffix array.
)

// suffixarray builds an index once and then answers substring/regex
// queries in sublinear time. Useful for many searches over the same text.
func runIndex() {
	text := []byte("the quick brown fox jumps over the lazy dog")
	idx := suffixarray.New(text)

	// Lookup returns byte offsets of every occurrence (up to n; -1 = all).
	fmt.Println("'the' offsets:", idx.Lookup([]byte("the"), -1))
	fmt.Println("'o'   offsets:", idx.Lookup([]byte("o"), -1))
}
