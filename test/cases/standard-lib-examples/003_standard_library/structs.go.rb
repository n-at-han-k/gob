# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/structs — Package structs defines marker types that can be used as struct fields to modify the properties of a struct.
require "structs"
# https://pkg.go.dev/unsafe — Package unsafe contains operations that step around the type safety of Go programs.
require "unsafe"
module Main
  # structs.HostLayout is a zero-size marker that tells the compiler this
  # struct's memory layout must match the host platform's C ABI rules.
  # It's meant for structs shared with syscalls or C code.
  class Stat
    attr_accessor :_
    attr_accessor :Dev
    attr_accessor :Ino
    attr_accessor :Mode
  end

  private

    def self.runStructs
      fmt.Println("size:", unsafe.Sizeof(Stat.new()))
      fmt.Println("align:", unsafe.Alignof(Stat.new()))
    end
end
