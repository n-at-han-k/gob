# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/runtime — Package runtime contains operations that interact with Go's runtime system.
require "runtime"
# https://pkg.go.dev/weak — Package weak provides ways to safely reference memory weakly, without preventing its reclamation.
require "weak"
module Main
  # weak.Pointer holds a reference that does NOT keep its target alive.
  # Once the GC collects the target, Value() starts returning nil.
  # Useful for caches that must not extend object lifetime.
  class Big
    attr_accessor :payload
  end

  private

    def self.runWeak
      strong = Big.new()
      w = weak.Make(strong)
      fmt.Println("before GC:", w.Value() != nil)
      strong = nil
      # drop the only strong reference
      runtime.GC()
      # ask the GC to reclaim it
      runtime.GC()
      # second pass for good measure
      fmt.Println("after GC: ", w.Value() != nil)
    end
end
