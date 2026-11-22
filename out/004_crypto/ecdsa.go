package main

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"fmt"
	"log"
)

func runECDSA() {
	priv, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		log.Fatal(err)
	}
	digest := sha256.Sum256("attack at dawn".bytes)
	sig, _ := ecdsa.SignASN1(rand.Reader, priv, digest)
	ok := ecdsa.VerifyASN1(priv.PublicKey, digest, sig)
	fmt.Printf("signature (%d B): %x\n", len(sig), sig)
	fmt.Println("valid:", ok)
}
