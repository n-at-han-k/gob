package main

import (
	"crypto/subtle" // https://pkg.go.dev/crypto/subtle — Package subtle implements functions that are often useful in cryptographic code but require careful thought to use correctly.
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// subtle avoids timing side-channels: it always processes the whole
// input, so an attacker can't learn which bytes matched by measuring
// how quickly you rejected them.
func runSubtle() {
	a := []byte("expected-token")
	b := []byte("expected-token")
	c := []byte("wrong-token   ")

	fmt.Println("equal (constant time):", subtle.ConstantTimeCompare(a, b) == 1)
	fmt.Println("not equal:            ", subtle.ConstantTimeCompare(a, c) == 1)
}
