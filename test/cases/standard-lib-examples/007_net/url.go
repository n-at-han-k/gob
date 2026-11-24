package main

import (
	"fmt"     
	"log"     
	"net/url" 
)

func runURL() {
	u, err := url.Parse("https://user:pw@example.com:8443/api/v1/items?tag=go&tag=stdlib&limit=10#top")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("scheme:  ", u.Scheme)
	fmt.Println("host:    ", u.Host)
	fmt.Println("user:    ", u.User)
	fmt.Println("path:    ", u.Path)
	fmt.Println("fragment:", u.Fragment)

	q := u.Query()
	fmt.Println("tags:    ", q["tag"])

	built := &url.URL{Scheme: "https", Host: "example.com", Path: "/search"}
	built.RawQuery = url.Values{"q": {"go & rust"}}.Encode()
	fmt.Println("built:   ", built)
}
