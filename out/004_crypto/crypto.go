package main

import (
	"crypto"
	"crypto/md5"
	"crypto/sha1"
	"crypto/sha256"
	"crypto/sha512"
	"fmt"
)

func runCrypto() {
	hashes := []any{crypto.MD5, crypto.SHA1, crypto.SHA256, crypto.SHA512}
	for _, h := range hashes {
		fmt.Printf("%-8s size=%d bytes available=%v\n", h, h.Size(), h.Available())
	}
}
