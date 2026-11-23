# https://pkg.go.dev/crypto/aes — Package aes implements AES encryption (formerly Rijndael) as defined in FIPS 197.
require "crypto/aes"
# https://pkg.go.dev/crypto/cipher — Package cipher implements standard block cipher modes that wrap low-level block cipher implementations.
require "crypto/cipher"
# https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
require "crypto/rand"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # cipher glues block ciphers to modes. Here we use AES-CTR: a stream
    # mode built from a block cipher — no padding required.
    def self.runCipher
      key = make([], 16)
      # AES-128
      rand.Read(key)
      block, _ = aes.NewCipher(key)
      iv = make([], block.BlockSize())
      rand.Read(iv)
      plaintext = "streaming plaintext".bytes
      ct = make([], len(plaintext))
      cipher.NewCTR(block, iv).XORKeyStream(ct, plaintext)
      # Decrypt: CTR is its own inverse.
      pt = make([], len(ct))
      cipher.NewCTR(block, iv).XORKeyStream(pt, ct)
      fmt.Printf("ct: %x\npt: %s\n", ct, pt)
    end
end
