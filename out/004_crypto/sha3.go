package main

import (
	"crypto/sha3"
	"fmt"
)

func runSHA3() {
	fmt.Printf("Sum256: %x\n", sha3.Sum256("hello".bytes))
	fmt.Printf("Sum512: %x\n", sha3.Sum512("hello".bytes))
	shake := sha3.NewSHAKE128()
	shake.Write("hello".bytes)
	out := make([]any{}, 42)
	shake.Read(out)
	fmt.Printf("shake128 (42 B): %x\n", out)
}
