package main

import (
	"bytes"
	"crypto/ecdh"
	"crypto/rand"
	"fmt"
	"log"
)

func runECDH() {
	curve := ecdh.P256()
	alice, err := curve.GenerateKey(rand.Reader)
	if err != nil {
		log.Fatal(err)
	}
	bob, _ := curve.GenerateKey(rand.Reader)
	shareA, _ := alice.ECDH(bob.PublicKey())
	shareB, _ := bob.ECDH(alice.PublicKey())
	fmt.Printf("shared secret (%d B): %x\n", len(shareA), shareA)
	fmt.Println("both sides agree:", bytes.Equal(shareA, shareB))
}
