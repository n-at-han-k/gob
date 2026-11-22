# https://pkg.go.dev/crypto/subtle — Package subtle implements functions that are often useful in cryptographic code but require careful thought to use correctly.
require "crypto/subtle"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # subtle avoids timing side-channels: it always processes the whole
    # input, so an attacker can't learn which bytes matched by measuring
    # how quickly you rejected them.
    def self.runSubtle
      a = "expected-token".bytes
      b = "expected-token".bytes
      c = "wrong-token   ".bytes
      fmt.Println("equal (constant time):", subtle.ConstantTimeCompare(a, b) == 1)
      fmt.Println("not equal:            ", subtle.ConstantTimeCompare(a, c) == 1)
    end
end
