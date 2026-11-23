package main

import (
	"crypto/rand" // https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
	"fmt"         // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"         // https://pkg.go.dev/log — Package log implements a simple logging package.
	"math/big"    // https://pkg.go.dev/math/big — Package big implements arbitrary-precision arithmetic.
)

// Prefer crypto/rand over math/rand whenever the output must be
// unpredictable (keys, nonces, tokens, session IDs).
func runRand() {
	buf := make([]byte, 16)
	if _, err := rand.Read(buf); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("random bytes: %x\n", buf)

	// Int returns a uniform integer in [0, max).
	n, _ := rand.Int(rand.Reader, big.NewInt(1_000_000))
	fmt.Println("random int  :", n)
}
