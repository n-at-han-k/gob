# https://pkg.go.dev/crypto/sha1 — Package sha1 implements the SHA-1 hash algorithm as defined in RFC 3174.
require "crypto/sha1"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # SHA-1 is broken for collision resistance; use SHA-256 or SHA-3 for
    # anything new. It survives in Git object IDs and some legacy protocols.
    def self.runSHA1
      sum = sha1.Sum("hello".bytes)
      fmt.Printf("sha1: %x\n", sum)
    end
end
