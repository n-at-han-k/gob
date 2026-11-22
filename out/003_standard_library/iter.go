package main

import (
	"fmt"
	"iter"
	"slices"
)

func countdown(from any) {
	return func(yield_ any) {
		i := from
		for i >= 0 {
			if yield(i) {
			} else {
				return
			}
			i -= 1
		}
	}
}

func runIter() {
	for n := range countdown(3) {
		fmt.Println(n)
	}
	for i, v := range slices.All([]any{"a", "b", "c"}) {
		fmt.Println(i, v)
	}
}
