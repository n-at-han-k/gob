package main

import (
	"encoding/pem" // https://pkg.go.dev/encoding/pem — Package pem implements the PEM data encoding, which originated in Privacy Enhanced Mail.
	"fmt"          // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"os"           // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
)

// PEM wraps binary data (usually DER) in a base64 envelope with
// -----BEGIN/END X----- markers. It's what .pem key and cert files use.
func runPEM() {
	block := &pem.Block{
		Type: "MESSAGE",
		Headers: map[string]string{
			"Comment": "learning-go example",
		},
		Bytes: []byte("some binary payload"),
	}
	pem.Encode(os.Stdout, block)

	// Round-trip: encode → decode → inspect.
	encoded := pem.EncodeToMemory(block)
	got, rest := pem.Decode(encoded)
	fmt.Printf("type=%s bytes=%q leftover=%d\n", got.Type, got.Bytes, len(rest))
}
