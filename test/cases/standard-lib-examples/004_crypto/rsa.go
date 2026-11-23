package main

import (
	"crypto"        // https://pkg.go.dev/crypto — Package crypto collects common cryptographic constants.
	"crypto/rand"   // https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
	"crypto/rsa"    // https://pkg.go.dev/crypto/rsa — Package rsa implements RSA encryption as specified in PKCS #1 and RFC 8017.
	"crypto/sha256" // https://pkg.go.dev/crypto/sha256 — Package sha256 implements the SHA224 and SHA256 hash algorithms.
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"           // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// RSA signing example (PSS is preferred over PKCS#1 v1.5 for new code).
func runRSA() {
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		log.Fatal(err)
	}

	digest := sha256.Sum256([]byte("sign me"))
	sig, err := rsa.SignPSS(rand.Reader, priv, crypto.SHA256, digest[:], nil)
	if err != nil {
		log.Fatal(err)
	}
	err = rsa.VerifyPSS(&priv.PublicKey, crypto.SHA256, digest[:], sig, nil)

	fmt.Printf("signature (%d bytes)\n", len(sig))
	fmt.Println("verify err:", err) // nil means success
}
