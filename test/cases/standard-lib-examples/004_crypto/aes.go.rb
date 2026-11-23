require "crypto/aes"
require "crypto/cipher"
require "crypto/rand"
require "fmt"
require "log"
module Main
  private

    def self.runAES
      key = make([], 32)
      rand.Read(key)
      block, err = aes.NewCipher(key)

      if err != nil
        log.Fatal(err)
      end

      gcm, _ = cipher.NewGCM(block)
      nonce = make([], gcm.NonceSize())
      rand.Read(nonce)
      plaintext = "secret message".bytes
      ct = gcm.Seal(nil, nonce, plaintext, nil)
      pt, err = gcm.Open(nil, nonce, ct, nil)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("ciphertext (%d bytes): %x\n", len(ct), ct)
      fmt.Printf("decrypted: %s\n", pt)
    end
end
