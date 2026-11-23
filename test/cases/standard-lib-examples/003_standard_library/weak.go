package main

import (
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"runtime" // https://pkg.go.dev/runtime — Package runtime contains operations that interact with Go's runtime system.
	"weak"    // https://pkg.go.dev/weak — Package weak provides ways to safely reference memory weakly, without preventing its reclamation.
)

// weak.Pointer holds a reference that does NOT keep its target alive.
// Once the GC collects the target, Value() starts returning nil.
// Useful for caches that must not extend object lifetime.
type big struct{ payload [1 << 20]byte }

func runWeak() {
	strong := &big{}
	w := weak.Make(strong)

	fmt.Println("before GC:", w.Value() != nil)

	strong = nil // drop the only strong reference
	runtime.GC() // ask the GC to reclaim it
	runtime.GC() // second pass for good measure

	fmt.Println("after GC: ", w.Value() != nil)
}
