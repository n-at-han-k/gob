package main

import (
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"net/http/fcgi" // https://pkg.go.dev/net/http/fcgi — Package fcgi implements the FastCGI protocol.
)

// fcgi speaks the FastCGI wire protocol used by nginx/Apache to talk to
// long-lived backend processes. Actually accepting requests needs a
// listening socket that the web server connects to, so we just show the
// API you'd hand off to fcgi.Serve.
func runFCGI() {
	// fcgi.Serve(l, handler) would be the real call — l is any net.Listener,
	// or nil to use the socket the web server passed on stdin.
	fmt.Printf("fcgi.Serve signature: %T\n", fcgi.Serve)
	fmt.Println("wire the handler up behind nginx via fastcgi_pass to see it run.")
}
