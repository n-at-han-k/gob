package main

import (
	"fmt" // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// runtime/race exports no public API — its job is to be linked in when
// you build with `-race`, at which point the compiler instruments every
// load and store and calls into this package to detect data races.
//
// Enable it for tests:
//
//	go test -race ./...
//
// or for binaries:
//
//	go build -race
//
// The detector adds ~5-10x memory and ~2-20x CPU overhead, so leave it
// off in production and turn it on in CI.
func runRace() {
	fmt.Println("runtime/race has no public API — it's the runtime side of `go build -race`.")
	fmt.Println("Build this program with -race and any concurrent unsynchronised access will")
	fmt.Println("be reported at the moment it happens.")
}
