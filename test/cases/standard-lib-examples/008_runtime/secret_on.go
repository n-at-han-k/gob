
package main

import (
	"fmt"            
	"runtime/secret" 
)

func runSecret() {
	key := []byte("hunter2-shhhh")

	secret.Do(func() {

		var mixed [16]byte
		for i := range mixed {
			mixed[i] = key[i%len(key)] ^ byte(i)
		}
		fmt.Printf("inside Do: mixed=%x, Enabled=%v\n", mixed, secret.Enabled())
	})

	fmt.Println("outside Do: registers and stack that Do touched are now zeroed.")
}
