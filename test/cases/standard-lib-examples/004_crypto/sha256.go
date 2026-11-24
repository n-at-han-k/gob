package main

import (
	"crypto/sha256"
	"fmt"
)

func runSHA256() {
	fmt.Printf("Sum256:   %x\n", sha256.Sum256([]byte("hello")))
	fmt.Printf("Sum224:   %x\n", sha256.Sum224([]byte("hello")))

	h := sha256.New()
	h.Write([]byte("hel"))
	h.Write([]byte("lo"))
	fmt.Printf("streamed: %x\n", h.Sum(nil))
}
