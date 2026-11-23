require "crypto/aes"
require "crypto/cipher"
require "crypto/rand"
require "fmt"
module Main
  private

    def self.runCipher
      key = make([], 16)
      rand.Read(key)
      block, _ = aes.NewCipher(key)
      iv = make([], block.BlockSize())
      rand.Read(iv)
      plaintext = "streaming plaintext".bytes
      ct = make([], len(plaintext))
      cipher.NewCTR(block, iv).XORKeyStream(ct, plaintext)
      pt = make([], len(ct))
      cipher.NewCTR(block, iv).XORKeyStream(pt, ct)
      fmt.Printf("ct: %x\npt: %s\n", ct, pt)
    end
end
