package main

import (
	"fmt"          // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"unicode"      // https://pkg.go.dev/unicode — Package unicode provides data and functions to test some properties of Unicode code points.
	"unicode/utf8" // https://pkg.go.dev/unicode/utf8 — Package utf8 implements functions and constants to support text encoded in UTF-8.
)

func runUnicode() {
	// Rune categorisation helpers.
	for _, r := range "Aa1!  你" {
		fmt.Printf("%q letter=%v digit=%v space=%v\n",
			r, unicode.IsLetter(r), unicode.IsDigit(r), unicode.IsSpace(r))
	}

	// Case conversion respects Unicode.
	fmt.Println(string(unicode.ToUpper('ß'))) // 'ß' has no ASCII upper form

	// utf8 works with the byte encoding.
	s := "héllo"
	fmt.Println("bytes:", len(s), "runes:", utf8.RuneCountInString(s))
}
