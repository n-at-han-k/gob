package main

import (
	"crypto/sha256" // https://pkg.go.dev/crypto/sha256 — Package sha256 implements the SHA224 and SHA256 hash algorithms as defined in FIPS 180-4.
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

func runSHA256() {
	fmt.Printf("Sum256:   %x\n", sha256.Sum256([]byte("hello")))
	fmt.Printf("Sum224:   %x\n", sha256.Sum224([]byte("hello")))

	// Streaming API for incremental input.
	h := sha256.New()
	h.Write([]byte("hel"))
	h.Write([]byte("lo"))
	fmt.Printf("streamed: %x\n", h.Sum(nil))
}
