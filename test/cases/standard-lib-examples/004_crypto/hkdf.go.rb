require "crypto/hkdf"
require "crypto/sha256"
require "fmt"
require "log"
module Main
  private

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
