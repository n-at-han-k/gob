package main

import (
	"crypto/ecdsa"    // https://pkg.go.dev/crypto/ecdsa — Package ecdsa implements the Elliptic Curve Digital Signature Algorithm as defined in FIPS 186-5.
	"crypto/elliptic" // https://pkg.go.dev/crypto/elliptic — Package elliptic implements the standard NIST P-224, P-256, P-384, and P-521 elliptic curves over prime fields.
	"crypto/rand"     // https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
	"crypto/sha256"   // https://pkg.go.dev/crypto/sha256 — Package sha256 implements the SHA224 and SHA256 hash algorithms.
	"fmt"             // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"             // https://pkg.go.dev/log — Package log implements a simple logging package.
)

func runECDSA() {
	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		log.Fatal(err)
	}

	digest := sha256.Sum256([]byte("attack at dawn"))
	sig, _ := ecdsa.SignASN1(rand.Reader, priv, digest[:])
	ok := ecdsa.VerifyASN1(&priv.PublicKey, digest[:], sig)

	fmt.Printf("signature (%d B): %x\n", len(sig), sig)
	fmt.Println("valid:", ok)
}
