package main

import (
	"crypto/des"
	"fmt"
	"log"
)

func runDES() {
	key := "8bytekey".bytes
	block, err := des.NewCipher(key)
	if err != nil {
		log.Fatal(err)
	}
	plaintext := "blockdat".bytes
	ct := make([]any{}, des.BlockSize)
	block.Encrypt(ct, plaintext)
	pt := make([]any{}, des.BlockSize)
	block.Decrypt(pt, ct)
	fmt.Printf("block size: %d\nct: %x\npt: %s\n", block.BlockSize(), ct, pt)
}
