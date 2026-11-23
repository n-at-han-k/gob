package main

import (
	"fmt"  // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"os"   // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
	"sort" // https://pkg.go.dev/sort — Package sort provides primitives for sorting slices and user-defined collections.
)

// Each *.go file in this directory demonstrates one runtime/* subpackage.
// Run one demo at a time, e.g.:
//
//	go run . metrics
//
// or list what's available with `go run .`.
var demos = map[string]func(){
	"runtime":  runRuntime,
	"cgo":      runCGO,
	"coverage": runCoverage,
	"debug":    runDebug,
	"metrics":  runMetrics,
	"pprof":    runPProf,
	"race":     runRace,
	"secret":   runSecret,
	"trace":    runTrace,
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("usage: go run . <package>")
		fmt.Println("available demos:")
		names := make([]string, 0, len(demos))
		for k := range demos {
			names = append(names, k)
		}
		sort.Strings(names)
		for _, n := range names {
			fmt.Println("  ", n)
		}
		return
	}
	demo, ok := demos[os.Args[1]]
	if !ok {
		fmt.Println("unknown demo:", os.Args[1])
		os.Exit(1)
	}
	demo()
}
