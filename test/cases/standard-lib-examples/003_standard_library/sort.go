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

	people := []person{{"C", 30}, {"A", 25}, {"B", 30}}
	sort.Slice(people, func(i, j int) bool {
		if people[i].Age != people[j].Age {
			return people[i].Age < people[j].Age
		}
		return people[i].Name < people[j].Name
	})
	fmt.Println("people:", people)

	sort.SliceStable(people, func(i, j int) bool { return people[i].Age < people[j].Age })
	fmt.Println("stable:", people)
}
