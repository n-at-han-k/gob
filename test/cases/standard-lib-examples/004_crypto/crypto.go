package main

import (
	"crypto"        // https://pkg.go.dev/crypto — Package crypto collects common cryptographic constants.
	_ "crypto/md5"  // register MD5 so crypto.MD5.Available() returns true
	_ "crypto/sha1" // register SHA-1
	_ "crypto/sha256"
	_ "crypto/sha512"
	"fmt" // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// The root crypto package only defines shared types (Hash, PublicKey,
// Signer, ...). Sub-packages must be blank-imported before their Hash
// value becomes Available.
func runCrypto() {
	hashes := []crypto.Hash{crypto.MD5, crypto.SHA1, crypto.SHA256, crypto.SHA512}
	for _, h := range hashes {
		fmt.Printf("%-8s size=%d bytes available=%v\n", h, h.Size(), h.Available())
	}
}
