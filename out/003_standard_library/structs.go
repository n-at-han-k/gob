package main

import (
	"fmt"
	"structs"
	"unsafe"
)

type Stat struct {
	_    any
	Dev  any
	Ino  any
	Mode any
}

func runStructs() {
	fmt.Println("size:", unsafe.Sizeof(Stat.new()))
	fmt.Println("align:", unsafe.Alignof(Stat.new()))
}
