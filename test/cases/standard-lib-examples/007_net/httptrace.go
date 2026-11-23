package main

import (
	"fmt"                // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"net/http"           // https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
	"net/http/httptest"  // https://pkg.go.dev/net/http/httptest — Package httptest provides utilities for HTTP testing.
	"net/http/httptrace" // https://pkg.go.dev/net/http/httptrace — Package httptrace provides mechanisms to trace the events within HTTP client requests.
)

// httptrace hooks into every phase of an outgoing request — DNS,
// connection reuse, TLS handshake, write start, first byte. Attach a
// ClientTrace via context and the transport calls the callbacks.
func runHTTPTrace() {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "hello")
	}))
	defer srv.Close()

	trace := &httptrace.ClientTrace{
		GetConn:              func(host string) { fmt.Println("GetConn:", host) },
		GotConn:              func(info httptrace.GotConnInfo) { fmt.Println("GotConn: reused=", info.Reused) },
		WroteHeaders:         func() { fmt.Println("WroteHeaders") },
		GotFirstResponseByte: func() { fmt.Println("GotFirstResponseByte") },
	}

	req, _ := http.NewRequest("GET", srv.URL, nil)
	req = req.WithContext(httptrace.WithClientTrace(req.Context(), trace))

	resp, _ := http.DefaultTransport.RoundTrip(req)
	resp.Body.Close()
	fmt.Println("status:", resp.Status)
}
