require "crypto/sha1"
require "fmt"
module Main
  private

    def self.runSHA1
      sum = sha1.Sum("hello".bytes)
      fmt.Printf("sha1: %x\n", sum)
    end
end
