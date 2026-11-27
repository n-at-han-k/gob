package main

import (
	"encoding/base64"
	"fmt"
	"log"
)

func runBase64() {
	src := ([]byte)("hello base64+/=?")
	std := base64.StdEncoding.EncodeToString(src)
	fmt.Println("std:", std)
	url := base64.URLEncoding.EncodeToString(src)
	fmt.Println("url:", url)
	fmt.Println("raw:", base64.RawURLEncoding.EncodeToString(src))
	back, err := base64.StdEncoding.DecodeString(std)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("decoded: %s\n", back)
}
