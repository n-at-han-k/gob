package main

import "fmt"

var pi = 3.14159

var statusActive = "active"

var statusInactive = "inactive"

var packageLevel = "I live at package scope"

func main() {
	a := 0
	b := ""
	c := false
	d := 0.0
	fmt.Println("zero values:", a, b, c, d)
	name := "Nathan"
	age := 30
	fmt.Println(name, age)
	city := "Wellington"
	country := "New Zealand"
	fmt.Println(city, country)
	x, y, z := []any{1, 2.5, "three"}
	fmt.Println(x, y, z)
	x, y = []any{10, 20.5}
	fmt.Println(x, y)
	host := "localhost"
	port := 8080
	enabled := true
	fmt.Println(host, port, enabled)
	count := 100
	big := int64(count) * 1000
	fmt.Println(big)
	greeting := "hi"
	fmt.Println(greeting, pi, statusActive, statusInactive)
	fmt.Println(packageLevel)
	shadow := "outer"
	shadow = "inner"
	fmt.Println(shadow)
	fmt.Println(shadow)
	swap1, swap2 := []any{"first", "second"}
	swap1, swap2 = []any{swap2, swap1}
	fmt.Println(swap1, swap2)
	_, kept := ignoreOne()
	fmt.Println(kept)
}

func ignoreOne() {
	return "discarded", "kept"
}
