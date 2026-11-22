package main

import (
	"bytes"
	"encoding/gob"
	"fmt"
	"log"
)

type Message struct {
	Kind any
	Body any
}

func runGob() {
	buf := nil
	enc := gob.NewEncoder(buf)
	err := enc.Encode(Message.new(map[any]any{Kind: "primes", Body: []any{2, 3, 5, 7, 11}}))
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("encoded %d bytes\n", buf.Len())
	back := nil
	err = gob.NewDecoder(buf).Decode(back)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("decoded: %+v\n", back)
}
