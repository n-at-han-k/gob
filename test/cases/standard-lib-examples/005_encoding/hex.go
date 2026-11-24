package main

import (
	"encoding/hex"
	"fmt"
	"log"
)

func runHex() {
	src := []byte("hello hex")

	encoded := hex.EncodeToString(src)
	fmt.Println("encoded:", encoded)

	back, err := hex.DecodeString(encoded)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("decoded: %s\n", back)

	fmt.Print(hex.Dump(src))
}
