package main

import (
	"crypto/elliptic" // https://pkg.go.dev/crypto/elliptic — Package elliptic implements the standard NIST P-224, P-256, P-384, and P-521 elliptic curves over prime fields.
	"fmt"             // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// The elliptic package now mostly exposes the NIST curves used by
// crypto/ecdsa and crypto/ecdh. Direct point arithmetic is deprecated.
func runElliptic() {
	for _, c := range []elliptic.Curve{elliptic.P224(), elliptic.P256(), elliptic.P384(), elliptic.P521()} {
		p := c.Params()
		fmt.Printf("%-6s bits=%d Gx=0x%x...\n", p.Name, p.BitSize, p.Gx.Bytes()[:4])
	}
}
