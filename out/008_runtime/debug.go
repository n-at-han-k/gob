package main

import (
	"fmt"
	"runtime/debug"
)

func runDebug() {
	info, ok := debug.ReadBuildInfo()
	if ok {
		fmt.Println("go version:", info.GoVersion)
		fmt.Println("main path: ", info.Main.Path)
		for _, s := range info.Settings {
			if s.Key == "vcs.revision" || s.Key == "GOARCH" || s.Key == "CGO_ENABLED" {
				fmt.Printf("  %s = %s\n", s.Key, s.Value)
			}
		}
	}
	stats := nil
	debug.ReadGCStats(stats)
	fmt.Printf("gc runs: %d, total pause: %v\n", stats.NumGC, stats.PauseTotal)
	stack := debug.Stack()
	if len(stack) > 200 {
		stack = stack[nil:200]
	}
	fmt.Print("stack:\n", string(stack), "...\n")
}
