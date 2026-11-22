package main

import (
	"crypto/rand"
	"fmt"
	"log"
	"math/big"
)

func runRand() {
	buf := make([]any{}, 16)
	_, err := rand.Read(buf)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("random bytes: %x\n", buf)
	n, _ := rand.Int(rand.Reader, big.NewInt(1000000))
	fmt.Println("random int  :", n)
}
