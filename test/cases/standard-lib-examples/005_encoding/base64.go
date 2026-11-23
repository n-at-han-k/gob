package main

import (
	"encoding/base64" // https://pkg.go.dev/encoding/base64 — Package base64 implements base64 encoding as specified by RFC 4648.
	"fmt"             // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"             // https://pkg.go.dev/log — Package log implements a simple logging package.
)

func runBase64() {
	src := []byte("hello base64+/=?")

	// StdEncoding uses '+', '/' and '=' padding.
	std := base64.StdEncoding.EncodeToString(src)
	fmt.Println("std:", std)

	// URLEncoding uses '-' and '_' so results are URL/filename safe.
	url := base64.URLEncoding.EncodeToString(src)
	fmt.Println("url:", url)

	// RawStdEncoding / RawURLEncoding drop the trailing '=' padding.
	fmt.Println("raw:", base64.RawURLEncoding.EncodeToString(src))

	back, err := base64.StdEncoding.DecodeString(std)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("decoded: %s\n", back)
}
