package main

import (
	"fmt"
	"os"
	"runtime/coverage"
)

func runCoverage() {
	dir, _ := os.MkdirTemp("", "cover-")
	defer func() {
		os.RemoveAll(dir)
	}()
	err := coverage.WriteMetaDir(dir)
	if err != nil {
		fmt.Println("WriteMetaDir:", err)
	} else {
		fmt.Println("wrote meta to", dir)
	}
	err = coverage.WriteCountersDir(dir)
	if err != nil {
		fmt.Println("WriteCountersDir:", err)
	}
	err = coverage.ClearCounters()
	if err != nil {
		fmt.Println("ClearCounters:", err)
	}
	fmt.Println("(rebuild with `go build -cover` for these to succeed)")
}
