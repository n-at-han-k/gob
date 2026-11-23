require "crypto/hmac"
require "crypto/sha256"
require "fmt"
module Main
  private

    def self.runHMAC
      key = "shared secret".bytes
      msg = "transfer $100".bytes
      mac = hmac.New(sha256.New, key)
      mac.Write(msg)
      tag = mac.Sum(nil)
      check = hmac.New(sha256.New, key)
      check.Write(msg)
      fmt.Printf("tag: %x\n", tag)
      fmt.Println("valid:", hmac.Equal(tag, check.Sum(nil)))
    end
end
