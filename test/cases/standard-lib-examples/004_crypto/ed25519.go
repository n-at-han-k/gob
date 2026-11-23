package main

import (
	"crypto/ed25519" // https://pkg.go.dev/crypto/ed25519 — Package ed25519 implements the Ed25519 signature algorithm.
	"crypto/rand"    // https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
	"fmt"            // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"            // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// Ed25519 is a modern, fast signature scheme with tiny keys/signatures.
func runED25519() {
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		log.Fatal(err)
	}

	msg := []byte("sign me")
	sig := ed25519.Sign(priv, msg)

	fmt.Printf("public key (%d B): %x\n", len(pub), pub)
	fmt.Printf("signature (%d B): %x\n", len(sig), sig)
	fmt.Println("valid:", ed25519.Verify(pub, msg, sig))
}
