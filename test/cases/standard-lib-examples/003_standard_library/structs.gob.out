package main

import (
	"fmt"
	"structs"
	"unsafe"
)

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
