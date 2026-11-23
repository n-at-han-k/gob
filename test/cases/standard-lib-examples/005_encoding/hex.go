package main

import (
	"encoding/hex" // https://pkg.go.dev/encoding/hex — Package hex implements hexadecimal encoding and decoding.
	"fmt"          // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"          // https://pkg.go.dev/log — Package log implements a simple logging package.
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

	// Dump is the pretty hex+ASCII form familiar from `xxd`.
	fmt.Print(hex.Dump(src))
}
