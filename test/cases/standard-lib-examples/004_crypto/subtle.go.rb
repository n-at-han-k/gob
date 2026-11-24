require "crypto/subtle"
require "fmt"

module Main

    # ()
    def runSubtle
      a = "expected-token".bytes
      b = "expected-token".bytes
      c = "wrong-token   ".bytes
      fmt.Println("equal (constant time):", subtle.ConstantTimeCompare(a, b) == 1)
      fmt.Println("not equal:            ", subtle.ConstantTimeCompare(a, c) == 1)
    end
end
