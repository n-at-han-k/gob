package main

import (
	"crypto/rc4"
	"fmt"
	"log"
)

func runRC4() {
	c, err := rc4.NewCipher([]byte("weakkey"))
	if err != nil {
		log.Fatal(err)
	}

	pt := []byte("legacy data")
	ct := make([]byte, len(pt))
	c.XORKeyStream(ct, pt)

	c2, _ := rc4.NewCipher([]byte("weakkey"))
	out := make([]byte, len(ct))
	c2.XORKeyStream(out, ct)

	fmt.Printf("ct: %x\npt: %s\n", ct, out)
}
