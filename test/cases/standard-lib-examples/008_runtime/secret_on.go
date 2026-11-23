//go:build goexperiment.runtimesecret

package main

import (
	"fmt"            // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"runtime/secret" // https://pkg.go.dev/runtime/secret — Package secret contains helper functions for zeroing out memory that is otherwise invisible to a user program in the service of forward secrecy.
)

// secret.Do runs a closure and then zeroes any stack and registers it
// touched. Intended for constant-time cryptographic code where you
// don't want a key sitting in memory after use.
func runSecret() {
	key := []byte("hunter2-shhhh")

	secret.Do(func() {
		// Pretend to do something with the key: XOR-mask a nonce, say.
		var mixed [16]byte
		for i := range mixed {
			mixed[i] = key[i%len(key)] ^ byte(i)
		}
		fmt.Printf("inside Do: mixed=%x, Enabled=%v\n", mixed, secret.Enabled())
	})

	fmt.Println("outside Do: registers and stack that Do touched are now zeroed.")
}
