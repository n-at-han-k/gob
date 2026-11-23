package main

import (
	"bytes"       // https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
	"crypto/ecdh" // https://pkg.go.dev/crypto/ecdh — Package ecdh implements Elliptic Curve Diffie-Hellman over NIST curves and Curve25519.
	"crypto/rand" // https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
	"fmt"         // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"         // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// Two parties agree on a shared secret over an insecure channel.
func runECDH() {
	curve := ecdh.P256()

	alice, err := curve.GenerateKey(rand.Reader)
	if err != nil {
		log.Fatal(err)
	}
	bob, _ := curve.GenerateKey(rand.Reader)

	// Each side derives the same shared secret from their own private key
	// and the other side's public key.
	shareA, _ := alice.ECDH(bob.PublicKey())
	shareB, _ := bob.ECDH(alice.PublicKey())

	fmt.Printf("shared secret (%d B): %x\n", len(shareA), shareA)
	fmt.Println("both sides agree:", bytes.Equal(shareA, shareB))
}
