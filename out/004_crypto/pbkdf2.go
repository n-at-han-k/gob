package main

import (
	"crypto/pbkdf2"
	"crypto/rand"
	"crypto/sha256"
	"fmt"
	"log"
)

func runPBKDF2() {
	salt := make([]any{}, 16)
	rand.Read(salt)
	key, err := pbkdf2.Key(sha256.New, "hunter2", salt, 100000, 32)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("salt: %x\nkey:  %x\n", salt, key)
}
