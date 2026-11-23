package main

import (
	"fmt"              // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"os"               // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
	"runtime/coverage" // https://pkg.go.dev/runtime/coverage — Package coverage contains APIs for writing coverage profile data at runtime from long-running programs.
)

// coverage lets a long-running server dump coverage snapshots without
// having to shut down. Only useful when the program was built with
// `go build -cover`; otherwise every write returns an error saying so.
func runCoverage() {
	dir, _ := os.MkdirTemp("", "cover-")
	defer os.RemoveAll(dir)

	if err := coverage.WriteMetaDir(dir); err != nil {
		fmt.Println("WriteMetaDir:", err)
	} else {
		fmt.Println("wrote meta to", dir)
	}
	if err := coverage.WriteCountersDir(dir); err != nil {
		fmt.Println("WriteCountersDir:", err)
	}
	if err := coverage.ClearCounters(); err != nil {
		fmt.Println("ClearCounters:", err)
	}
	fmt.Println("(rebuild with `go build -cover` for these to succeed)")
}
