package main

import (
	"fmt"
	"sort"
)

type Person struct {
	Name any
	Age  any
}

func runSort() {
	nums := []any{5, 2, 4, 1, 3}
	sort.Ints(nums)
	fmt.Println("ints:", nums)
	people := []any{[]any{"C", 30}, []any{"A", 25}, []any{"B", 30}}
	sort.Slice(people, func(i any, j any) {
		if people[i].Age != people[j].Age {
			return people[i].Age < people[j].Age
		}
		return people[i].Name < people[j].Name
	})
	fmt.Println("people:", people)
	sort.SliceStable(people, func(i any, j any) {
		return people[i].Age < people[j].Age
	})
	fmt.Println("stable:", people)
}
