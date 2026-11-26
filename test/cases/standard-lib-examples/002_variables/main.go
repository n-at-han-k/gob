package main

import "fmt"

const pi = 3.14159

const statusActive = "active"
const statusInactive = "inactive"

var packageLevel = "I live at package scope"

func main() {
	var a int
	var b string
	var c bool
	var d float64

	fmt.Println("zero values:", a, b, c, d)

	var name string = "Nathan"
	var age int = 30
	fmt.Println(name, age)

	city := "Wellington"
	country := "New Zealand"
	fmt.Println(city, country)

	x, y, z := 1, 2.5, "three"
	fmt.Println(x, y, z)

	x, y = 10, 20.5
	fmt.Println(x, y)

	host := "localhost"
	port := 8080
	enabled := true
	fmt.Println(host, port, enabled)

	var count int32 = 100
	var big int64 = int64(count) * 1000
	fmt.Println(big)

	const greeting = "hi"
	fmt.Println(greeting, pi, statusActive, statusInactive)

	fmt.Println(packageLevel)

	shadow := "outer"
	{
		shadow := "inner"
		fmt.Println(shadow)
	}
	fmt.Println(shadow)

	swap1, swap2 := "first", "second"
	swap1, swap2 = swap2, swap1
	fmt.Println(swap1, swap2)

	_, kept := ignoreOne()
	fmt.Println(kept)
}

func ignoreOne() (string, string) {
	return "discarded", "kept"
}
