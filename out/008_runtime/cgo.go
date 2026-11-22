package main

import (
	"fmt"
	"runtime/cgo"
)

func runCGO() {
	original := map[any]any{"answer": 42}
	h := cgo.NewHandle(original)
	defer func() {
		h.Delete()
	}()
	got := h.Value()
	fmt.Printf("handle: %d\n", uintptr(h))
	fmt.Printf("value:  %v\n", got)
	got["answer"] = 99
	fmt.Printf("mutation visible on original: %v\n", original["answer"] == 99)
}
