package main

import (
	"fmt"
	"sort"
)

type person struct {
	Name string
	Age  int
}

func runSort() {
	nums := []int{5, 2, 4, 1, 3}
	sort.Ints(nums)
	fmt.Println("ints:", nums)
	people := []person{
		person{"C", 30},
		person{"A", 25},
		person{"B", 30},
	}
	sort.Slice(people, func(i int, j int) bool {
		left := people[i]
		right := people[j]
		if left.Age != right.Age {
			return left.Age < right.Age
		}
		return left.Name < right.Name
	})
	fmt.Println("people:", people)
	sort.SliceStable(people, func(i int, j int) bool {
		left := people[i]
		right := people[j]
		return left.Age < right.Age
	})
	fmt.Println("stable:", people)
}
