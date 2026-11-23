package main

import (
	"crypto/tls" // https://pkg.go.dev/crypto/tls — Package tls partially implements TLS 1.2 (RFC 5246) and TLS 1.3 (RFC 8446).
	"fmt"        // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// TLS setup is usually done via net/http (which builds a tls.Config
// under the hood). This demo just inspects the defaults — spinning up
// a real listener is out of scope here.
func runTLS() {
	cfg := &tls.Config{
		MinVersion: tls.VersionTLS12,
		NextProtos: []string{"h2", "http/1.1"},
	}
	fmt.Printf("min version: 0x%04x (TLS 1.2)\n", cfg.MinVersion)
	fmt.Println("ALPN offers:", cfg.NextProtos)

	// A dialer example (not executed):
	//
	//   conn, err := tls.Dial("tcp", "example.com:443", cfg)
	//   defer conn.Close()
	//   state := conn.ConnectionState()
	//   fmt.Println("negotiated:", tls.VersionName(state.Version))
}
