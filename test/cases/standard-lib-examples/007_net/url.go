package main

import (
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"     // https://pkg.go.dev/log — Package log implements a simple logging package.
	"net/url" // https://pkg.go.dev/net/url — Package url parses URLs and implements query escaping.
)

// net/url parses and builds URLs safely: scheme, host, path, query and
// fragment are exposed as separate fields with proper escaping helpers.
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

	// Build a URL from scratch, letting net/url escape values.
	built := &url.URL{Scheme: "https", Host: "example.com", Path: "/search"}
	built.RawQuery = url.Values{"q": {"go & rust"}}.Encode()
	fmt.Println("built:   ", built)
}
