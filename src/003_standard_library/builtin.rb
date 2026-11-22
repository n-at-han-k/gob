# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # The builtin package is documentation-only; it lists predeclared
    # identifiers like len, cap, make, new, append, copy, delete, panic,
    # recover, print, min, max. This file demonstrates them.
    def self.runBuiltin
      # make creates slices, maps, and channels with initial capacity.
      s = make([], 0, 4)
      # append grows a slice, returning the possibly-new backing array.
      s = append(s, 1, 2, 3)
      fmt.Println("len/cap:", len(s), cap(s))
      # copy duplicates slice contents.
      dst = make([], 3)
      copy(dst, s)
      fmt.Println("copied:", dst)
      # new returns a pointer to a zero-valued T.
      p = new(int)
      p = 42
      fmt.Println("new int:", p)
      # delete removes a key from a map.
      m = { "a" => 1, "b" => 2 }
      delete(m, "a")
      fmt.Println("map:", m)
      # min/max work on any ordered type (Go 1.21+).
      fmt.Println("min/max:", min(3, 1, 2), max(3, 1, 2))

      # recover turns a panic into a normal error value.
      defer do
        r = recover()

        if r != nil
          fmt.Println("recovered:", r)
        end
      end.()

      panic("boom")
    end
end
