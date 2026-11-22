package main

import (
	"crypto/rc4"
	"fmt"
	"log"
)

func runRC4() {
	c, err := rc4.NewCipher("weakkey".bytes)
	if err != nil {
		log.Fatal(err)
	}
	pt := "legacy data".bytes
	ct := make([]any{}, len(pt))
	c.XORKeyStream(ct, pt)
	c2, _ := rc4.NewCipher("weakkey".bytes)
	out := make([]any{}, len(ct))
	c2.XORKeyStream(out, ct)
	fmt.Printf("ct: %x\npt: %s\n", ct, out)
}
