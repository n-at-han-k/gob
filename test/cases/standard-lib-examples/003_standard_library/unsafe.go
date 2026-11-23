package main

import (
	"fmt"    // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"unsafe" // https://pkg.go.dev/unsafe — Package unsafe contains operations that step around the type safety of Go programs.
)

// unsafe steps around Go's type system. Use it only when you must —
// interop with syscalls, tight zero-copy conversions, or reflection.
type header struct {
	Flag byte
	Len  uint32
}

func runUnsafe() {
	// Size and alignment of a type in memory.
	fmt.Println("Sizeof header:  ", unsafe.Sizeof(header{}))
	fmt.Println("Alignof header: ", unsafe.Alignof(header{}))
	fmt.Println("Offsetof Len:   ", unsafe.Offsetof(header{}.Len))

	// Zero-copy conversion between []byte and string (Go 1.20+).
	b := []byte("hello")
	s := unsafe.String(&b[0], len(b))
	fmt.Println("string view:", s)

	// The reverse direction.
	bytes := unsafe.Slice(unsafe.StringData("world"), 5)
	fmt.Println("byte view:  ", bytes)
}
