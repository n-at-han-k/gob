package main

import (
	"crypto/dsa"    // https://pkg.go.dev/crypto/dsa — Package dsa implements the Digital Signature Algorithm as defined in FIPS 186-3.
	"crypto/rand"   // https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
	"crypto/sha256" // https://pkg.go.dev/crypto/sha256 — Package sha256 implements the SHA224 and SHA256 hash algorithms.
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"           // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// DSA is legacy; prefer ECDSA or Ed25519 for new signatures.
func runDSA() {
	var params dsa.Parameters
	if err := dsa.GenerateParameters(&params, rand.Reader, dsa.L1024N160); err != nil {
		log.Fatal(err)
	}

	priv := &dsa.PrivateKey{PublicKey: dsa.PublicKey{Parameters: params}}
	if err := dsa.GenerateKey(priv, rand.Reader); err != nil {
		log.Fatal(err)
	}

	digest := sha256.Sum256([]byte("hello"))
	r, s, err := dsa.Sign(rand.Reader, priv, digest[:])
	if err != nil {
		log.Fatal(err)
	}
	ok := dsa.Verify(&priv.PublicKey, digest[:], r, s)
	fmt.Println("signature valid:", ok)
}
