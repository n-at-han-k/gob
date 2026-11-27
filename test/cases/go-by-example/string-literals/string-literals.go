package main

import "fmt"

func main() {
	// Interpreted string literals
	s := "hello\nworld"
	fmt.Println(s)
	fmt.Println("")
	fmt.Println("say \"hi\"")
	// Raw string literal
	raw := `raw\nliteral`
	fmt.Println(raw)
	// Rune literals
	a := 'a'
	nl := '\n'
	tab := '\t'
	sq := '\''
	bs := '\\'
	hex := '\x41'
	uni := '\u0041'
	fmt.Println(a)
	fmt.Println(nl)
	fmt.Println(tab)
	fmt.Println(sq)
	fmt.Println(bs)
	fmt.Println(hex)
	fmt.Println(uni)
	// Rune literals in comparisons
	r := 't'
	if r == 't' {
		fmt.Println("tee")
	}
	if r != 'x' {
		fmt.Println("not x")
	}
	// Rune literal as byte arg
	b := make([]byte, 1)
	b[0] = 'A'
	fmt.Println(b[0])
}
