package main

import (
	"crypto/hkdf"
	"crypto/sha256"
	"fmt"
	"log"
)

func runHKDF() {
	secret := []byte("some shared secret bytes")
	salt := []byte("optional salt")
	info := []byte("app: session key v1")

	key, err := hkdf.Key(sha256.New, secret, salt, string(info), 32)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("derived 32-byte key: %x\n", key)
}
