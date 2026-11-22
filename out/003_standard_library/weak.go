package main

import (
	"fmt"
	"runtime"
	"weak"
)

type Big struct {
	payload any
}

func runWeak() {
	strong := Big.new()
	w := weak.Make(strong)
	fmt.Println("before GC:", w.Value() != nil)
	strong = nil
	runtime.GC()
	runtime.GC()
	fmt.Println("after GC: ", w.Value() != nil)
}
