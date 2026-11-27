package main

import (
	"fmt"
	"index/suffixarray"
)

func runIndex() {
	text := ([]byte)("the quick brown fox jumps over the lazy dog")
	idx := suffixarray.New(text)
	fmt.Println("'the' offsets:", idx.Lookup(([]byte)("the"), -1))
	fmt.Println("'o'   offsets:", idx.Lookup(([]byte)("o"), -1))
}
