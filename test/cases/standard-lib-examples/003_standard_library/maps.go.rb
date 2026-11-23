# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/maps — Package maps defines various functions useful with maps of any type.
require "maps"
# https://pkg.go.dev/slices — Package slices defines various functions useful with slices of any type.
require "slices"
module Main
  private

    def self.runMaps
      m = { "a" => 1, "b" => 2, "c" => 3 }
      # Keys/Values return iterators; collect them into a slice to sort.
      keys = slices.Sorted(maps.Keys(m))
      fmt.Println("keys:", keys)
      # Clone makes a shallow copy of a map.
      cp = maps.Clone(m)
      cp["a"] = 99
      fmt.Println("orig:", m, "clone:", cp)
      # Equal compares two maps for equality.
      fmt.Println("equal:", maps.Equal(m, { "a" => 1, "b" => 2, "c" => 3 }))
      # DeleteFunc removes entries matching a predicate.
      maps.DeleteFunc(m, lambda { |k, v| return v > 1 })
      fmt.Println("after delete:", m)
    end
end
