# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/unique — Package unique provides facilities for canonicalizing ("interning") comparable values.
require "unique"
module Main
  private

    # unique.Make canonicalises ("interns") comparable values, so equal
    # values share memory and pointer comparison is O(1). Useful for lots
    # of repeated small values (labels, enum-like strings).
    def self.runUnique
      a = unique.Make("hello")
      b = unique.Make("hello")
      c = unique.Make("world")
      # Handles compare by identity, not by contents.
      fmt.Println("a == b:", a == b)
      # true — same underlying storage
      fmt.Println("a == c:", a == c)
      # false
      # Value() unwraps the handle back to the original value.
      fmt.Println("value:", a.Value())
    end
end
