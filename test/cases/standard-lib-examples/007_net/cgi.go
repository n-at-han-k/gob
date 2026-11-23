package main

import (
	"fmt"          // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"net/http"     // https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
	"net/http/cgi" // https://pkg.go.dev/net/http/cgi — Package cgi implements CGI (Common Gateway Interface) as specified in RFC 3875.
	"net/http/httptest" // https://pkg.go.dev/net/http/httptest — Package httptest provides utilities for HTTP testing.
	"os"           // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
)

// CGI has two sides: cgi.Handler wraps an external CGI binary as an
// http.Handler, and cgi.Serve runs the *current* process as a CGI
// child. We demo the second: pretend the web server invoked us.
func runCGI() {
	// Fake the environment a real web server would set.
	os.Setenv("REQUEST_METHOD", "GET")
	os.Setenv("SERVER_PROTOCOL", "HTTP/1.1")
	os.Setenv("HTTP_HOST", "example.local")
	os.Setenv("PATH_INFO", "/hello")
	os.Setenv("QUERY_STRING", "who=world")

	// httptest.NewRecorder captures the response so we can print it.
	rec := httptest.NewRecorder()
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "CGI script saw %s with %s=%s\n", r.URL.Path, "who", r.URL.Query().Get("who"))
	})

	req, _ := cgi.RequestFromMap(map[string]string{
		"REQUEST_METHOD":  os.Getenv("REQUEST_METHOD"),
		"SERVER_PROTOCOL": os.Getenv("SERVER_PROTOCOL"),
		"HTTP_HOST":       os.Getenv("HTTP_HOST"),
		"REQUEST_URI":     os.Getenv("PATH_INFO") + "?" + os.Getenv("QUERY_STRING"),
		"CONTENT_LENGTH":  "0",
	})
	handler.ServeHTTP(rec, req)
	fmt.Print(rec.Body.String())
}
