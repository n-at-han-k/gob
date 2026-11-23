package main

import (
	"crypto/rc4" // https://pkg.go.dev/crypto/rc4 — Package rc4 implements RC4 encryption.
	"fmt"        // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"        // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// RC4 is broken; the package exists purely for interop with legacy
// protocols. Do not use it for new code.
func runRC4() {
	c, err := rc4.NewCipher([]byte("weakkey"))
	if err != nil {
		log.Fatal(err)
	}

	pt := []byte("legacy data")
	ct := make([]byte, len(pt))
	c.XORKeyStream(ct, pt)

	// Encrypt again with a fresh cipher to decrypt (RC4 is XOR-based).
	c2, _ := rc4.NewCipher([]byte("weakkey"))
	out := make([]byte, len(ct))
	c2.XORKeyStream(out, ct)

	fmt.Printf("ct: %x\npt: %s\n", ct, out)
}
