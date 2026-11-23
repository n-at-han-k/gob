# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/unsafe — Package unsafe contains operations that step around the type safety of Go programs.
require "unsafe"
module Main
  # unsafe steps around Go's type system. Use it only when you must —
  # interop with syscalls, tight zero-copy conversions, or reflection.
  class Header
    attr_accessor :Flag
    attr_accessor :Len
  end

  private

    def self.runUnsafe
      # Size and alignment of a type in memory.
      fmt.Println("Sizeof header:  ", unsafe.Sizeof(Header.new()))
      fmt.Println("Alignof header: ", unsafe.Alignof(Header.new()))
      fmt.Println("Offsetof Len:   ", unsafe.Offsetof(Header.new().Len))
      # Zero-copy conversion between []byte and string (Go 1.20+).
      b = "hello".bytes
      s = unsafe.String(b[0], len(b))
      fmt.Println("string view:", s)
      # The reverse direction.
      bytes = unsafe.Slice(unsafe.StringData("world"), 5)
      fmt.Println("byte view:  ", bytes)
    end
end
