package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"fmt"
)

func runCipher() {
	key := make([]any{}, 16)
	rand.Read(key)
	block, _ := aes.NewCipher(key)
	iv := make([]any{}, block.BlockSize())
	rand.Read(iv)
	plaintext := "streaming plaintext".bytes
	ct := make([]any{}, len(plaintext))
	cipher.NewCTR(block, iv).XORKeyStream(ct, plaintext)
	pt := make([]any{}, len(ct))
	cipher.NewCTR(block, iv).XORKeyStream(pt, ct)
	fmt.Printf("ct: %x\npt: %s\n", ct, pt)
}
