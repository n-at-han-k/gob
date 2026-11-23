package main

import (
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"structs" // https://pkg.go.dev/structs — Package structs defines marker types that can be used as struct fields to modify the properties of a struct.
	"unsafe"  // https://pkg.go.dev/unsafe — Package unsafe contains operations that step around the type safety of Go programs.
)

// structs.HostLayout is a zero-size marker that tells the compiler this
// struct's memory layout must match the host platform's C ABI rules.
// It's meant for structs shared with syscalls or C code.
type stat struct {
	_    structs.HostLayout
	Dev  uint64
	Ino  uint64
	Mode uint32
}

func runStructs() {
	fmt.Println("size:", unsafe.Sizeof(stat{}))
	fmt.Println("align:", unsafe.Alignof(stat{}))
}
