package main

import (
	"encoding/pem"
	"fmt"
	"os"
)

func runPEM() {
	block := &pem.Block{
		Type: "MESSAGE",
		Headers: map[string]string{
			"Comment": "learning-go example",
		},
		Bytes: []byte("some binary payload"),
	}
	pem.Encode(os.Stdout, block)

	encoded := pem.EncodeToMemory(block)
	got, rest := pem.Decode(encoded)
	fmt.Printf("type=%s bytes=%q leftover=%d\n", got.Type, got.Bytes, len(rest))
}
