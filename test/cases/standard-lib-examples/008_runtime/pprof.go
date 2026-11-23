package main

import (
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"os"            // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
	"runtime"       // https://pkg.go.dev/runtime — Package runtime contains operations that interact with Go's runtime system.
	"runtime/pprof" // https://pkg.go.dev/runtime/pprof — Package pprof writes runtime profiling data in the format expected by the pprof visualization tool.
)

// runtime/pprof is the library equivalent of net/http/pprof: same
// profile data (heap, goroutine, CPU, ...), but written to any writer.
func runPProf() {
	// Force some allocations so the heap profile isn't empty.
	junk := make([][]byte, 0, 100)
	for range 100 {
		junk = append(junk, make([]byte, 1024))
	}
	runtime.GC() // sample the live heap.

	f, err := os.CreateTemp("", "heap-*.prof")
	if err != nil {
		fmt.Println("temp:", err)
		return
	}
	defer os.Remove(f.Name())
	defer f.Close()

	if err := pprof.Lookup("heap").WriteTo(f, 0); err != nil {
		fmt.Println("write:", err)
		return
	}
	info, _ := f.Stat()
	fmt.Printf("wrote heap profile: %s (%d bytes)\n", f.Name(), info.Size())
	fmt.Println("view with: go tool pprof", f.Name())

	// Ensure junk stays live to the profile call.
	_ = junk
}
