# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  class Point
    attr_accessor :X
    attr_accessor :Y
  end

  private

    def self.runFmt
      # Println: space-separated, newline terminated.
      fmt.Println("hello", 42, true)
      # Printf: format verbs. See https://pkg.go.dev/fmt for the full list.
      fmt.Printf("%d + %d = %d\n", 2, 3, 2 + 3)
      fmt.Printf("%.2f pi\n", 3.14159)
      fmt.Printf("%q quoted\n", "text")
      fmt.Printf("%v vs %+v vs %#v\n", Point.new(1, 2), Point.new(1, 2), Point.new(1, 2))
      fmt.Printf("%b %o %x hex\n", 255, 255, 255)
      fmt.Printf("%-10s|%10s|\n", "left", "right")
      # Sprintf returns the formatted string instead of printing it.
      s = fmt.Sprintf("year=%d", 2026)
      fmt.Println(s)
      # Errorf builds an error value.
      err = fmt.Errorf("bad input: %s", "nope")
      fmt.Println(err)
    end
end
