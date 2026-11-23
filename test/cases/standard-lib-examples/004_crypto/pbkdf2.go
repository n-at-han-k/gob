package main

import (
	"crypto/pbkdf2" // https://pkg.go.dev/crypto/pbkdf2 — Package pbkdf2 implements the key derivation function PBKDF2 as defined in RFC 8018.
	"crypto/rand"   // https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
	"crypto/sha256" // https://pkg.go.dev/crypto/sha256 — Package sha256 implements the SHA224 and SHA256 hash algorithms.
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"           // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// PBKDF2 stretches a low-entropy password into a key using a salt and
// many iterations. Use a modern algorithm (Argon2) for new designs, but
// PBKDF2 is common in legacy formats.
func runPBKDF2() {
	salt := make([]byte, 16)
	rand.Read(salt)

	key, err := pbkdf2.Key(sha256.New, "hunter2", salt, 100_000, 32)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("salt: %x\nkey:  %x\n", salt, key)
}
