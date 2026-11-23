package main

import (
	"bytes" // https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
	"fmt"   // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

func runBytes() {
	a := []byte("hello world")
	b := []byte("world")

	fmt.Println("Contains:", bytes.Contains(a, b))
	fmt.Println("Index:", bytes.Index(a, b))
	fmt.Println("ToUpper:", string(bytes.ToUpper(a)))
	fmt.Println("Split:", bytes.Split(a, []byte(" ")))
	fmt.Println("Replace:", string(bytes.ReplaceAll(a, b, []byte("gopher"))))

	// Buffer is a growable byte buffer implementing io.Reader/Writer.
	var buf bytes.Buffer
	buf.WriteString("one ")
	buf.WriteString("two ")
	fmt.Fprintf(&buf, "three=%d", 3)
	fmt.Println("buffer:", buf.String())
}
