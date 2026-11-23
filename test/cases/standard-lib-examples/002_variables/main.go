package main

import "fmt"

// Untyped constant; the compiler infers its type from usage.
const pi = 3.14159

// Grouped constants share a single const block for readability.
const (
	statusActive   = "active"
	statusInactive = "inactive"
)

// Package-level variable, accessible from anywhere in this package.
var packageLevel = "I live at package scope"

func main() {
	// Variables declared without a value are set to their type's zero value.
	var a int
	var b string
	var c bool
	var d float64

	fmt.Println("zero values:", a, b, c, d)

	// Explicit type with an initializer; the type could be omitted here.
	var name string = "Nathan"
	var age int = 30
	fmt.Println(name, age)

	// Short variable declaration; only valid inside functions.
	city := "Wellington"
	country := "New Zealand"
	fmt.Println(city, country)

	// Multiple assignment with mixed inferred types on one line.
	x, y, z := 1, 2.5, "three"
	fmt.Println(x, y, z)

	// Reassigning existing variables uses = instead of :=.
	x, y = 10, 20.5
	fmt.Println(x, y)

	// Grouped var block, handy for related configuration values.
	var (
		host    = "localhost"
		port    = 8080
		enabled = true
	)
	fmt.Println(host, port, enabled)

	// Go requires an explicit conversion when mixing numeric types.
	var count int32 = 100
	var big int64 = int64(count) * 1000
	fmt.Println(big)

	// Local constants are scoped to the function they're declared in.
	const greeting = "hi"
	fmt.Println(greeting, pi, statusActive, statusInactive)

	fmt.Println(packageLevel)

	// The inner block declares a new `shadow` that hides the outer one.
	shadow := "outer"
	{
		shadow := "inner"
		fmt.Println(shadow)
	}
	fmt.Println(shadow)

	// Tuple assignment swaps values without a temporary variable.
	swap1, swap2 := "first", "second"
	swap1, swap2 = swap2, swap1
	fmt.Println(swap1, swap2)

	// The blank identifier _ discards a return value we don't need.
	_, kept := ignoreOne()
	fmt.Println(kept)
}

// Functions can return multiple values, common for (result, error) pairs.
func ignoreOne() (string, string) {
	return "discarded", "kept"
}
