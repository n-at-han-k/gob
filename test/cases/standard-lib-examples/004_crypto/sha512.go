package main

import (
	"crypto/sha512" // https://pkg.go.dev/crypto/sha512 — Package sha512 implements the SHA-384, SHA-512, SHA-512/224, and SHA-512/256 hash algorithms as defined in FIPS 180-4.
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

func runSHA512() {
	fmt.Printf("Sum384:     %x\n", sha512.Sum384([]byte("hello")))
	fmt.Printf("Sum512:     %x\n", sha512.Sum512([]byte("hello")))
	fmt.Printf("Sum512_256: %x\n", sha512.Sum512_256([]byte("hello")))
}
