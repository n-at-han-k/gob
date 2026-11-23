require "crypto/rand"
require "fmt"
require "log"
require "math/big"
module Main
  private

    def self.runRand
      buf = make([], 16)
      _, err = rand.Read(buf)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("random bytes: %x\n", buf)
      n, _ = rand.Int(rand.Reader, big.NewInt(1_000_000))
      fmt.Println("random int  :", n)
    end
end
