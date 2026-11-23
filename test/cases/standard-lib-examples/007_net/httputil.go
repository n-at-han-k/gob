package main

import (
	"fmt"               // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"net/http"          // https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
	"net/http/httptest" // https://pkg.go.dev/net/http/httptest — Package httptest provides utilities for HTTP testing.
	"net/http/httputil" // https://pkg.go.dev/net/http/httputil — Package httputil provides HTTP utility functions, complementing the more common ones in the net/http package.
	"net/url"           // https://pkg.go.dev/net/url — Package url parses URLs and implements query escaping.
)

// httputil's headline feature is ReverseProxy — a drop-in http.Handler
// that forwards requests to another server and streams the response
// back. Below we proxy /* to a small upstream and print what the client
// sees.
func runHTTPUtil() {
	upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "upstream got %s\n", r.URL.Path)
	}))
	defer upstream.Close()

	target, _ := url.Parse(upstream.URL)
	proxy := httptest.NewServer(httputil.NewSingleHostReverseProxy(target))
	defer proxy.Close()

	resp, _ := http.Get(proxy.URL + "/echo")
	dump, _ := httputil.DumpResponse(resp, true)
	fmt.Print(string(dump))
}
