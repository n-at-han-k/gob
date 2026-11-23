package main

import (
	"fmt"  // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"sort" // https://pkg.go.dev/sort — Package sort provides primitives for sorting slices and user-defined collections.
)

type person struct {
	Name string
	Age  int
}

func runSort() {
	// Sort built-in slice types with the helpers.
	nums := []int{5, 2, 4, 1, 3}
	sort.Ints(nums)
	fmt.Println("ints:", nums)

	// Sort a struct slice with a custom Less function.
	people := []person{{"C", 30}, {"A", 25}, {"B", 30}}
	sort.Slice(people, func(i, j int) bool {
		if people[i].Age != people[j].Age {
			return people[i].Age < people[j].Age
		}
		return people[i].Name < people[j].Name
	})
	fmt.Println("people:", people)

	// SliceStable preserves the relative order of equal elements.
	sort.SliceStable(people, func(i, j int) bool { return people[i].Age < people[j].Age })
	fmt.Println("stable:", people)
}
