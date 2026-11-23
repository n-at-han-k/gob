package main

import (
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"runtime/debug" // https://pkg.go.dev/runtime/debug — Package debug contains facilities for programs to debug themselves while they are running.
)

// runtime/debug is a grab-bag: build info (module path, VCS commit),
// GC controls, and a snapshot of the current goroutine's stack.
func runDebug() {
	if info, ok := debug.ReadBuildInfo(); ok {
		fmt.Println("go version:", info.GoVersion)
		fmt.Println("main path: ", info.Main.Path)
		for _, s := range info.Settings {
			if s.Key == "vcs.revision" || s.Key == "GOARCH" || s.Key == "CGO_ENABLED" {
				fmt.Printf("  %s = %s\n", s.Key, s.Value)
			}
		}
	}

	var stats debug.GCStats
	debug.ReadGCStats(&stats)
	fmt.Printf("gc runs: %d, total pause: %v\n", stats.NumGC, stats.PauseTotal)

	// First few lines of the caller's stack.
	stack := debug.Stack()
	if len(stack) > 200 {
		stack = stack[:200]
	}
	fmt.Print("stack:\n", string(stack), "...\n")
}
