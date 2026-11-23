package main

import (
	"crypto/md5" // https://pkg.go.dev/crypto/md5 — Package md5 implements the MD5 hash algorithm as defined in RFC 1321.
	"fmt"        // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// MD5 is broken for security uses (collisions are trivial) but is still
// fine as a fast, non-cryptographic checksum for caches or file IDs.
func runMD5() {
	sum := md5.Sum([]byte("hello"))
	fmt.Printf("md5: %x\n", sum)

	// Streaming API for hashing large inputs incrementally.
	h := md5.New()
	h.Write([]byte("hel"))
	h.Write([]byte("lo"))
	fmt.Printf("streamed: %x\n", h.Sum(nil))
}
