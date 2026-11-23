package main

import (
	"crypto/fips140" // https://pkg.go.dev/crypto/fips140 — Package fips140 provides information about the FIPS 140-3 Go Cryptographic Module and FIPS 140-3 mode.
	"fmt"            // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// Enabled reports whether the process is running in FIPS 140-3 mode
// (toggled via GODEBUG=fips140=on at build/run time).
func runFIPS140() {
	fmt.Println("FIPS 140-3 mode enabled:", fips140.Enabled())
	fmt.Println("module version:         ", fips140.Version())
}
