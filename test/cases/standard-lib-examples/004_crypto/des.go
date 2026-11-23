package main

import (
	"crypto/des" // https://pkg.go.dev/crypto/des — Package des implements DES and TDEA as defined in FIPS 46-3.
	"fmt"        // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"        // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// DES is broken; keep this only to demonstrate the block cipher API.
// Use AES for anything real.
func runDES() {
	key := []byte("8bytekey") // DES key = 8 bytes
	block, err := des.NewCipher(key)
	if err != nil {
		log.Fatal(err)
	}

	plaintext := []byte("blockdat") // must be exactly one block (8 B)
	ct := make([]byte, des.BlockSize)
	block.Encrypt(ct, plaintext)

	pt := make([]byte, des.BlockSize)
	block.Decrypt(pt, ct)

	fmt.Printf("block size: %d\nct: %x\npt: %s\n", block.BlockSize(), ct, pt)
}
