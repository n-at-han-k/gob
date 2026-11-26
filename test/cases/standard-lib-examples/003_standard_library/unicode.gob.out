package main

import (
	"fmt"
	"unicode"
	"unicode/utf8"
)

func runUnicode() {
	for _, r := range "Aa1!  你" {
		fmt.Printf("%q letter=%v digit=%v space=%v\n", r, unicode.IsLetter(r), unicode.IsDigit(r), unicode.IsSpace(r))
	}
	fmt.Println(string(unicode.ToUpper("ß")))
	s := "héllo"
	fmt.Println("bytes:", len(s), "runes:", utf8.RuneCountInString(s))
}
