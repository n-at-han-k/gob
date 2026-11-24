package main

import (
	"crypto/sha1" 
	"fmt"         
)

func runSHA1() {
	sum := sha1.Sum([]byte("hello"))
	fmt.Printf("sha1: %x\n", sum)
}
