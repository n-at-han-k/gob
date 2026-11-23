package main

import (
	"bytes"        // https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
	"encoding/gob" // https://pkg.go.dev/encoding/gob — Package gob manages streams of gobs — binary values exchanged between an Encoder (transmitter) and a Decoder (receiver).
	"fmt"          // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"          // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// gob is a Go-native binary format that carries type info with the value,
// so the decoder knows how to reconstruct concrete types. Ideal for RPC
// between Go processes; not portable to other languages.
type message struct {
	Kind string
	Body []int
}

func runGob() {
	var buf bytes.Buffer

	enc := gob.NewEncoder(&buf)
	if err := enc.Encode(message{Kind: "primes", Body: []int{2, 3, 5, 7, 11}}); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("encoded %d bytes\n", buf.Len())

	var back message
	if err := gob.NewDecoder(&buf).Decode(&back); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("decoded: %+v\n", back)
}
