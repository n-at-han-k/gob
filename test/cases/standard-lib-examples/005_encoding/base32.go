package main

import (
	"encoding/base32" // https://pkg.go.dev/encoding/base32 — Package base32 implements base32 encoding as specified by RFC 4648.
	"fmt"             // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"             // https://pkg.go.dev/log — Package log implements a simple logging package.
)

func runBase32() {
	src := []byte("hello base32")

	// StdEncoding uses A-Z and 2-7 with '=' padding.
	encoded := base32.StdEncoding.EncodeToString(src)
	fmt.Println("std:  ", encoded)

	decoded, err := base32.StdEncoding.DecodeString(encoded)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("decoded: %s\n", decoded)

	// HexEncoding uses 0-9, A-V for lexical sort order.
	fmt.Println("hex:  ", base32.HexEncoding.EncodeToString(src))
}
