package main

import (
	"crypto/hmac"   // https://pkg.go.dev/crypto/hmac — Package hmac implements the Keyed-Hash Message Authentication Code (FIPS 198).
	"crypto/sha256" // https://pkg.go.dev/crypto/sha256 — Package sha256 implements the SHA224 and SHA256 hash algorithms.
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// HMAC proves a message was created by someone who knows the key.
// Always compare tags with hmac.Equal (constant time).
func runHMAC() {
	key := []byte("shared secret")
	msg := []byte("transfer $100")

	mac := hmac.New(sha256.New, key)
	mac.Write(msg)
	tag := mac.Sum(nil)

	// Verifier recomputes and compares.
	check := hmac.New(sha256.New, key)
	check.Write(msg)
	fmt.Printf("tag: %x\n", tag)
	fmt.Println("valid:", hmac.Equal(tag, check.Sum(nil)))
}
