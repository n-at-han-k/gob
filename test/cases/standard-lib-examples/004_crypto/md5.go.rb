# https://pkg.go.dev/crypto/md5 — Package md5 implements the MD5 hash algorithm as defined in RFC 1321.
require "crypto/md5"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # MD5 is broken for security uses (collisions are trivial) but is still
    # fine as a fast, non-cryptographic checksum for caches or file IDs.
    def self.runMD5
      sum = md5.Sum("hello".bytes)
      fmt.Printf("md5: %x\n", sum)
      # Streaming API for hashing large inputs incrementally.
      h = md5.New()
      h.Write("hel".bytes)
      h.Write("lo".bytes)
      fmt.Printf("streamed: %x\n", h.Sum(nil))
    end
end
