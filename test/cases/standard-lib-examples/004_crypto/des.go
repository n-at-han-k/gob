package main

import (
	"crypto/des"
	"fmt"
	"log"
)

func runDES() {
	key := ([]byte)("8bytekey")
	block, err := des.NewCipher(key)
	if err != nil {
		log.Fatal(err)
	}
	plaintext := ([]byte)("blockdat")
	ct := make([]byte, des.BlockSize)
	block.Encrypt(ct, plaintext)
	pt := make([]byte, des.BlockSize)
	block.Decrypt(pt, ct)
	fmt.Printf("block size: %d\nct: %x\npt: %s\n", block.BlockSize(), ct, pt)
}
