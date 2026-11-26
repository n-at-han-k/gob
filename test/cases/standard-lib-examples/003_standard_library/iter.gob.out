package main

import (
	"fmt"
	"iter"
	"slices"
)

func countdown(from int) iter.Seq[int] {
	return func(callback func(int) bool) {
		i := from
		for i >= 0 {
			if !callback(i) {
				return
			}
			i = i - 1
		}
	}
}

func runIter() {
	for n := range countdown(3) {
		fmt.Println(n)
	}
	for i, v := range slices.All([]string{"a", "b", "c"}) {
		fmt.Println(i, v)
	}
}
