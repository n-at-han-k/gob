package main

import (
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"runtime" // https://pkg.go.dev/runtime — Package runtime contains operations that interact with Go's runtime system, such as functions to control goroutines.
)

// runtime exposes the moving parts of the Go runtime: version, OS/arch,
// goroutine and CPU counts, caller info, and a memory-stats snapshot.
func runRuntime() {
	fmt.Println("go version:  ", runtime.Version())
	fmt.Println("GOOS/GOARCH: ", runtime.GOOS, runtime.GOARCH)
	fmt.Println("NumCPU:      ", runtime.NumCPU())
	fmt.Println("NumGoroutine:", runtime.NumGoroutine())
	fmt.Println("GOMAXPROCS:  ", runtime.GOMAXPROCS(0))

	// Caller info: file + line of the current call site.
	pc, file, line, _ := runtime.Caller(0)
	fmt.Printf("here: %s:%d (%s)\n", file, line, runtime.FuncForPC(pc).Name())

	// Memory stats snapshot.
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	fmt.Printf("heap alloc: %d KiB, sys: %d KiB, num GC: %d\n",
		m.HeapAlloc/1024, m.Sys/1024, m.NumGC)
}
