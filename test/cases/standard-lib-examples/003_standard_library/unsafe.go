package main

import (
	"fmt"
	"unsafe"
)

type header struct {
	Flag byte
	Len  uint32
}

func runUnsafe() {

	fmt.Println("Sizeof header:  ", unsafe.Sizeof(header{}))
	fmt.Println("Alignof header: ", unsafe.Alignof(header{}))
	fmt.Println("Offsetof Len:   ", unsafe.Offsetof(header{}.Len))

	b := []byte("hello")
	s := unsafe.String(&b[0], len(b))
	fmt.Println("string view:", s)

	bytes := unsafe.Slice(unsafe.StringData("world"), 5)
	fmt.Println("byte view:  ", bytes)
}
