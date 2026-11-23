# https://pkg.go.dev/crypto/des — Package des implements DES and TDEA as defined in FIPS 46-3.
require "crypto/des"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # DES is broken; keep this only to demonstrate the block cipher API.
    # Use AES for anything real.
    def self.runDES
      key = "8bytekey".bytes
      # DES key = 8 bytes
      block, err = des.NewCipher(key)

      if err != nil
        log.Fatal(err)
      end

      plaintext = "blockdat".bytes
      # must be exactly one block (8 B)
      ct = make([], des.BlockSize)
      block.Encrypt(ct, plaintext)
      pt = make([], des.BlockSize)
      block.Decrypt(pt, ct)
      fmt.Printf("block size: %d\nct: %x\npt: %s\n", block.BlockSize(), ct, pt)
    end
end
