package main

import (
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"strconv" // https://pkg.go.dev/strconv — Package strconv implements conversions to and from string representations of basic data types.
)

func runStrconv() {
	// Number → string.
	fmt.Println("Itoa:      ", strconv.Itoa(42))
	fmt.Println("FormatFloat:", strconv.FormatFloat(3.14, 'f', 2, 64))
	fmt.Println("FormatBool:", strconv.FormatBool(true))

	// String → number, returning errors on bad input.
	n, err := strconv.Atoi("100")
	fmt.Println("Atoi:", n, err)

	f, _ := strconv.ParseFloat("2.718", 64)
	fmt.Println("ParseFloat:", f)

	// Quote / Unquote for safe Go string literals.
	fmt.Println("Quote:  ", strconv.Quote(`hello "world"`))
	unq, _ := strconv.Unquote(`"hi\n"`)
	fmt.Printf("Unquote: %q\n", unq)
}
