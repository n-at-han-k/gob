package main

import (
	"encoding/pem"
	"fmt"
	"os"
)

func runPEM() {
	block := Block.new(map[any]any{Type: "MESSAGE", Headers: map[any]any{"Comment": "learning-go example"}, Bytes: "some binary payload".bytes})
	pem.Encode(os.Stdout, block)
	encoded := pem.EncodeToMemory(block)
	got, rest := pem.Decode(encoded)
	fmt.Printf("type=%s bytes=%q leftover=%d\n", got.Type, got.Bytes, len(rest))
}
