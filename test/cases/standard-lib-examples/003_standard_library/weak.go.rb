require "fmt"
require "runtime"
require "weak"
module Main
  class Big
    attr_accessor :payload
  end

  private

    def self.runWeak
      strong = Big.new()
      w = weak.Make(strong)
      fmt.Println("before GC:", w.Value() != nil)
      strong = nil
      runtime.GC()
      runtime.GC()
      fmt.Println("after GC: ", w.Value() != nil)
    end
end
