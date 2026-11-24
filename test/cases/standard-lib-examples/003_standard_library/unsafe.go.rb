require "fmt"
require "unsafe"

module Main
  class Header
    attr_accessor :Flag
    attr_accessor :Len
  end


    # ()
    def runUnsafe
      fmt.Println("Sizeof header:  ", unsafe.Sizeof(Header.new()))
      fmt.Println("Alignof header: ", unsafe.Alignof(Header.new()))
      fmt.Println("Offsetof Len:   ", unsafe.Offsetof(Header.new().Len))
      b = "hello".bytes
      s = unsafe.String(b[0], len(b))
      fmt.Println("string view:", s)
      bytes = unsafe.Slice(unsafe.StringData("world"), 5)
      fmt.Println("byte view:  ", bytes)
    end
end
