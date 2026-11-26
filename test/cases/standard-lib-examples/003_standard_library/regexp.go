package main

import (
	"fmt"
	"regexp"
)

func runRegexp() {

	re := regexp.MustCompile(`(\w+)@(\w+\.\w+)`)

	text := "contact nathan@example.com or admin@test.org"

	fmt.Println("match?     ", re.MatchString(text))
	fmt.Println("first:     ", re.FindString(text))
	fmt.Println("all:       ", re.FindAllString(text, -1))
	fmt.Println("submatches:", re.FindStringSubmatch("nathan@example.com"))

	fmt.Println("replaced:  ", re.ReplaceAllString(text, "$1 [at] $2"))
}
