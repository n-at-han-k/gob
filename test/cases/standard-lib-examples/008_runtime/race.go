package main

import (
	"fmt"
)

func runRace() {
	fmt.Println("runtime/race has no public API — it's the runtime side of `go build -race`.")
	fmt.Println("Build this program with -race and any concurrent unsynchronised access will")
	fmt.Println("be reported at the moment it happens.")
}
