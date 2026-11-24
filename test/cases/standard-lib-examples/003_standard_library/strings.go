package main

import (
	"fmt"     
	"strings" 
)

func runStrings() {
	s := "The quick brown fox jumps over the lazy dog"

	fmt.Println("Upper:      ", strings.ToUpper(s))
	fmt.Println("Contains:   ", strings.Contains(s, "fox"))
	fmt.Println("Count 'o':  ", strings.Count(s, "o"))
	fmt.Println("Fields:     ", strings.Fields(s))
	fmt.Println("Split:      ", strings.Split(s, " "))
	fmt.Println("Replace:    ", strings.Replace(s, "fox", "cat", 1))
	fmt.Println("HasPrefix:  ", strings.HasPrefix(s, "The"))
	fmt.Println("TrimSpace:  ", strings.TrimSpace("   pad   "))

	var b strings.Builder
	for _, w := range []string{"one", "two", "three"} {
		b.WriteString(w)
		b.WriteByte(' ')
	}
	fmt.Println("Builder:    ", strings.TrimSpace(b.String()))
}
