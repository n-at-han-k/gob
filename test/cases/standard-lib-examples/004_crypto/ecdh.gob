require "bytes"
require "crypto/ecdh"
require "crypto/rand"
require "fmt"
require "log"

module Main

    # ()
    def runECDH
      curve = ecdh.P256()
      alice, err = curve.GenerateKey(rand.Reader)

      if err != nil
        log.Fatal(err)
      end

      bob, _ = curve.GenerateKey(rand.Reader)
      shareA, _ = alice.ECDH(bob.PublicKey())
      shareB, _ = bob.ECDH(alice.PublicKey())
      fmt.Printf("shared secret (%d B): %x\n", len(shareA), shareA)
      fmt.Println("both sides agree:", bytes.Equal(shareA, shareB))
    end
end
