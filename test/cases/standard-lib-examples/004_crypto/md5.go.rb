require "crypto/md5"
require "fmt"
module Main
  private

    def self.runMD5
      sum = md5.Sum("hello".bytes)
      fmt.Printf("md5: %x\n", sum)
      h = md5.New()
      h.Write("hel".bytes)
      h.Write("lo".bytes)
      fmt.Printf("streamed: %x\n", h.Sum(nil))
    end
end
