package main

import (
	"fmt"
	"unique"
)

func runUnique() {
	a := unique.Make("hello")
	b := unique.Make("hello")
	c := unique.Make("world")

	fmt.Println("a == b:", a == b)
	fmt.Println("a == c:", a == c)

	fmt.Println("value:", a.Value())
}
