package main

import (
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"io"            // https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
	"log"           // https://pkg.go.dev/log — Package log implements a simple logging package.
	"net/http"      // https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
	"net/http/httptest" // https://pkg.go.dev/net/http/httptest — Package httptest provides utilities for HTTP testing.
)

// Spin up a real server on a random localhost port and hit it with the
// default client. No network access to the outside world required.
func runHTTP() {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "hello %s, you asked for %s\n", r.RemoteAddr, r.URL.Path)
	}))
	defer srv.Close()

	resp, err := http.Get(srv.URL + "/greet")
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	fmt.Println("status:", resp.Status)
	fmt.Print("body:  ", string(body))
}
