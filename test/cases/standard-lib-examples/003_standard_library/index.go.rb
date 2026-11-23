require "fmt"
require "index/suffixarray"
module Main
  private

    def self.runIndex
      text = "the quick brown fox jumps over the lazy dog".bytes
      idx = suffixarray.New(text)
      fmt.Println("'the' offsets:", idx.Lookup("the".bytes, -1))
      fmt.Println("'o'   offsets:", idx.Lookup("o".bytes, -1))
    end
end
