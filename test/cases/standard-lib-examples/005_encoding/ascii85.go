package main

import (
	"encoding/ascii85" // https://pkg.go.dev/encoding/ascii85 — Package ascii85 implements the ascii85 data encoding used in btoa and Adobe PostScript/PDF.
	"fmt"              // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

func runAscii85() {
	src := []byte("hello ascii85")
	dst := make([]byte, ascii85.MaxEncodedLen(len(src)))
	n := ascii85.Encode(dst, src)
	dst = dst[:n]
	fmt.Printf("encoded: %s\n", dst)

	// Decode returns (ndst, nsrc, err); ascii85 tolerates whitespace in src.
	back := make([]byte, len(src))
	ndst, _, err := ascii85.Decode(back, dst, true)
	if err != nil {
		fmt.Println("decode err:", err)
		return
	}
	fmt.Printf("decoded: %s\n", back[:ndst])
}
