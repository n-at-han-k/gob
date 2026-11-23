require "crypto/sha256"
require "fmt"
module Main
  private

    def self.runSHA256
      fmt.Printf("Sum256:   %x\n", sha256.Sum256("hello".bytes))
      fmt.Printf("Sum224:   %x\n", sha256.Sum224("hello".bytes))
      h = sha256.New()
      h.Write("hel".bytes)
      h.Write("lo".bytes)
      fmt.Printf("streamed: %x\n", h.Sum(nil))
    end
end
