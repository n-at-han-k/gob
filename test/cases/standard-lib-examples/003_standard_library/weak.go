package main

import (
	"fmt"
	"runtime"
	"weak"
)

type big struct {
	payload [1_048_576]byte
}

func runWeak() {
	strong := &big{}
	w := weak.Make(strong)
	fmt.Println("before GC:", w.Value() != nil)
	strong = nil
	runtime.GC()
	runtime.GC()
	fmt.Println("after GC: ", w.Value() != nil)
}
