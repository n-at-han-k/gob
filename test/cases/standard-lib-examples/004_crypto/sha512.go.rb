require "crypto/sha512"
require "fmt"
module Main
  private

    def self.runSHA512
      fmt.Printf("Sum384:     %x\n", sha512.Sum384("hello".bytes))
      fmt.Printf("Sum512:     %x\n", sha512.Sum512("hello".bytes))
      fmt.Printf("Sum512_256: %x\n", sha512.Sum512_256("hello".bytes))
    end
end
