package main

import (
	"bytes"        // https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
	"crypto/mlkem" // https://pkg.go.dev/crypto/mlkem — Package mlkem implements the quantum-resistant key encapsulation method ML-KEM (formerly Kyber), NIST FIPS 203.
	"fmt"          // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"          // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// ML-KEM is the post-quantum key encapsulation mechanism NIST standardised
// as FIPS 203. Use the encapsulation key to derive a shared secret and a
// ciphertext; the holder of the decapsulation key recovers the same secret.
func runMLKEM() {
	dk, err := mlkem.GenerateKey768()
	if err != nil {
		log.Fatal(err)
	}
	ek := dk.EncapsulationKey()

	shared1, ct := ek.Encapsulate()
	shared2, err := dk.Decapsulate(ct)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("shared secret (%d B): %x\n", len(shared1), shared1)
	fmt.Println("both sides agree:", bytes.Equal(shared1, shared2))
}
