require "fmt"
require "runtime/cgo"

module Main

    # ()
    def runCGO
      original = { "answer" => 42 }
      h = cgo.NewHandle(original)
      defer { h.Delete() }
      got = h.Value()
      fmt.Printf("handle: %d\n", uintptr(h))
      fmt.Printf("value:  %v\n", got)
      got["answer"] = 99
      fmt.Printf("mutation visible on original: %v\n", original["answer"] == 99)
    end
end
