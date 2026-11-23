require "crypto/des"
require "fmt"
require "log"
module Main
  private

    def self.runDES
      key = "8bytekey".bytes
      block, err = des.NewCipher(key)

      if err != nil
        log.Fatal(err)
      end

      plaintext = "blockdat".bytes
      ct = make([], des.BlockSize)
      block.Encrypt(ct, plaintext)
      pt = make([], des.BlockSize)
      block.Decrypt(pt, ct)
      fmt.Printf("block size: %d\nct: %x\npt: %s\n", block.BlockSize(), ct, pt)
    end
end
