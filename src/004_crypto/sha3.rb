# https://pkg.go.dev/crypto/sha3 — Package sha3 implements the SHA-3 hash algorithms and SHAKE extendable output functions (FIPS 202).
require "crypto/sha3"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # SHA-3 is a different sponge-based construction from SHA-2 (which
    # crypto/sha256 and crypto/sha512 implement). SHAKE variants let you
    # ask for any output length.
    def self.runSHA3
      fmt.Printf("Sum256: %x\n", sha3.Sum256("hello".bytes))
      fmt.Printf("Sum512: %x\n", sha3.Sum512("hello".bytes))
      # SHAKE128 as an extendable output function.
      shake = sha3.NewSHAKE128()
      shake.Write("hello".bytes)
      out = make([], 42)
      shake.Read(out)
      fmt.Printf("shake128 (42 B): %x\n", out)
    end
end
