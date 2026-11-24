package main

import (
	"fmt"
	"runtime/cgo"
)

func runCGO() {
	original := map[string]int{"answer": 42}

	h := cgo.NewHandle(original)
	defer h.Delete()

	got := h.Value().(map[string]int)
	fmt.Printf("handle: %d\n", uintptr(h))
	fmt.Printf("value:  %v\n", got)
	got["answer"] = 99
	fmt.Printf("mutation visible on original: %v\n", original["answer"] == 99)
}
