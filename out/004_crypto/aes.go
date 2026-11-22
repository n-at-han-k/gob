package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"fmt"
	"log"
)

func runAES() {
	key := make([]any{}, 32)
	rand.Read(key)
	block, err := aes.NewCipher(key)
	if err != nil {
		log.Fatal(err)
	}
	gcm, _ := cipher.NewGCM(block)
	nonce := make([]any{}, gcm.NonceSize())
	rand.Read(nonce)
	plaintext := "secret message".bytes
	ct := gcm.Seal(nil, nonce, plaintext, nil)
	pt, err := gcm.Open(nil, nonce, ct, nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("ciphertext (%d bytes): %x\n", len(ct), ct)
	fmt.Printf("decrypted: %s\n", pt)
}
