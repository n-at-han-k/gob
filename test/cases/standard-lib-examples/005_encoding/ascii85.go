package main

import (
	"encoding/ascii85"
	"fmt"
)

func runAscii85() {
	src := ([]byte)("hello ascii85")
	dst := make([]byte, ascii85.MaxEncodedLen(len(src)))
	n := ascii85.Encode(dst, src)
	dst = dst[:n]
	fmt.Printf("encoded: %s\n", dst)
	back := make([]byte, len(src))
	ndst, _, err := ascii85.Decode(back, dst, true)
	if err != nil {
		fmt.Println("decode err:", err)
		return
	}
	fmt.Printf("decoded: %s\n", back[:ndst])
}
