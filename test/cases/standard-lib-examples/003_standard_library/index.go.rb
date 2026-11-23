# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/index/suffixarray — Package suffixarray implements substring search in logarithmic time using a suffix array.
require "index/suffixarray"
module Main
  private

    # suffixarray builds an index once and then answers substring/regex
    # queries in sublinear time. Useful for many searches over the same text.
    def self.runIndex
      text = "the quick brown fox jumps over the lazy dog".bytes
      idx = suffixarray.New(text)
      # Lookup returns byte offsets of every occurrence (up to n; -1 = all).
      fmt.Println("'the' offsets:", idx.Lookup("the".bytes, -1))
      fmt.Println("'o'   offsets:", idx.Lookup("o".bytes, -1))
    end
end
