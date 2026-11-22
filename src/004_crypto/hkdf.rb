# https://pkg.go.dev/crypto/hkdf — Package hkdf implements the HMAC-based Extract-and-Expand Key Derivation Function (RFC 5869).
require "crypto/hkdf"
# https://pkg.go.dev/crypto/sha256 — Package sha256 implements the SHA224 and SHA256 hash algorithms.
require "crypto/sha256"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # HKDF turns a high-entropy input (an ECDH shared secret, say) into
    # as many independent subkeys as you like.
    def self.runHKDF
      secret = "some shared secret bytes".bytes
      salt = "optional salt".bytes
      info = "app: session key v1".bytes
      key, err = hkdf.Key(sha256.New, secret, salt, string(info), 32)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("derived 32-byte key: %x\n", key)
    end
end
