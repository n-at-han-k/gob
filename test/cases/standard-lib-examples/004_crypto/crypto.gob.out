package main

import (
	"crypto"
	_ "crypto/md5"
	_ "crypto/sha1"
	_ "crypto/sha256"
	_ "crypto/sha512"
	"fmt"
)

func runCrypto() {
	hashes := []crypto.Hash{crypto.MD5, crypto.SHA1, crypto.SHA256, crypto.SHA512}
	for _, h := range hashes {
		fmt.Printf("%-8s size=%d bytes available=%v\n", h, h.Size(), h.Available())
	}
}
