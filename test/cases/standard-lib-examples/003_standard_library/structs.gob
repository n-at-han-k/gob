require "fmt"
require "structs"
require "unsafe"

module Main
  class Stat
    attr_accessor :_
    attr_accessor :Dev
    attr_accessor :Ino
    attr_accessor :Mode
  end


    # ()
    def runStructs
      fmt.Println("size:", unsafe.Sizeof(Stat.new()))
      fmt.Println("align:", unsafe.Alignof(Stat.new()))
    end
end
