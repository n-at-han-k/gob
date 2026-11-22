package main

import (
	"crypto/dsa"
	"crypto/rand"
	"crypto/sha256"
	"fmt"
	"log"
)

func runDSA() {
	params := nil
	err := dsa.GenerateParameters(params, rand.Reader, dsa.L1024N160)
	if err != nil {
		log.Fatal(err)
	}
	priv := PrivateKey.new(map[any]any{PublicKey: PublicKey.new(map[any]any{Parameters: params})})
	err = dsa.GenerateKey(priv, rand.Reader)
	if err != nil {
		log.Fatal(err)
	}
	digest := sha256.Sum256("hello".bytes)
	r, s, err := dsa.Sign(rand.Reader, priv, digest)
	if err != nil {
		log.Fatal(err)
	}
	ok := dsa.Verify(priv.PublicKey, digest, r, s)
	fmt.Println("signature valid:", ok)
}
