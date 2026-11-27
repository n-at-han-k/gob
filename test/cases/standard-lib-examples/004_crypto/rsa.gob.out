package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"fmt"
	"log"
)

func runRSA() {
	priv, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		log.Fatal(err)
	}
	digest := sha256.Sum256(([]byte)("sign me"))
	sig, err := rsa.SignPSS(rand.Reader, priv, crypto.SHA256, digest[:], nil)
	if err != nil {
		log.Fatal(err)
	}
	err = rsa.VerifyPSS(&priv.PublicKey, crypto.SHA256, digest[:], sig, nil)
	fmt.Printf("signature (%d bytes)\n", len(sig))
	fmt.Println("verify err:", err)
}
