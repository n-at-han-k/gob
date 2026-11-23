package main

import (
	"crypto/aes"    // https://pkg.go.dev/crypto/aes — Package aes implements AES encryption (formerly Rijndael) as defined in FIPS 197.
	"crypto/cipher" // https://pkg.go.dev/crypto/cipher — Package cipher implements standard block cipher modes that wrap low-level block cipher implementations.
	"crypto/rand"   // https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"           // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// AES is a block cipher; you almost always wrap it in an AEAD mode like
// GCM so you get authenticated encryption in one step.
func runAES() {
	key := make([]byte, 32) // AES-256
	rand.Read(key)

	block, err := aes.NewCipher(key)
	if err != nil {
		log.Fatal(err)
	}
	gcm, _ := cipher.NewGCM(block)

	nonce := make([]byte, gcm.NonceSize())
	rand.Read(nonce)

	plaintext := []byte("secret message")
	ct := gcm.Seal(nil, nonce, plaintext, nil)
	pt, err := gcm.Open(nil, nonce, ct, nil)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("ciphertext (%d bytes): %x\n", len(ct), ct)
	fmt.Printf("decrypted: %s\n", pt)
}
