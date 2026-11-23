# https://pkg.go.dev/crypto/sha512 — Package sha512 implements the SHA-384, SHA-512, SHA-512/224, and SHA-512/256 hash algorithms as defined in FIPS 180-4.
require "crypto/sha512"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    def self.runSHA512
      fmt.Printf("Sum384:     %x\n", sha512.Sum384("hello".bytes))
      fmt.Printf("Sum512:     %x\n", sha512.Sum512("hello".bytes))
      fmt.Printf("Sum512_256: %x\n", sha512.Sum512_256("hello".bytes))
    end
end
