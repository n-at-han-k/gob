package main

import (
	"crypto/elliptic"
	"fmt"
)

func runElliptic() {
	for _, c := range []elliptic.Curve{elliptic.P224(), elliptic.P256(), elliptic.P384(), elliptic.P521()} {
		p := c.Params()
		fmt.Printf("%-6s bits=%d Gx=0x%x...\n", p.Name, p.BitSize, p.Gx.Bytes()[:4])
	}
}
