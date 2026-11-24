package main

import (
	"fmt"    
	"iter"   
	"slices" 
)

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

	for i, v := range slices.All([]string{"a", "b", "c"}) {
		fmt.Println(i, v)
	}
}
