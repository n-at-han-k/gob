# https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
require "crypto/rand"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/math/big — Package big implements arbitrary-precision arithmetic.
require "math/big"
module Main
  private

    # Prefer crypto/rand over math/rand whenever the output must be
    # unpredictable (keys, nonces, tokens, session IDs).
    def self.runRand
      buf = make([], 16)
      _, err = rand.Read(buf)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("random bytes: %x\n", buf)
      # Int returns a uniform integer in [0, max).
      n, _ = rand.Int(rand.Reader, big.NewInt(1_000_000))
      fmt.Println("random int  :", n)
    end
end
