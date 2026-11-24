require "crypto/ed25519"
require "crypto/rand"
require "fmt"
require "log"

module Main

    # ()
    def runED25519
      pub, priv, err = ed25519.GenerateKey(rand.Reader)

      if err != nil
        log.Fatal(err)
      end

      msg = "sign me".bytes
      sig = ed25519.Sign(priv, msg)
      fmt.Printf("public key (%d B): %x\n", len(pub), pub)
      fmt.Printf("signature (%d B): %x\n", len(sig), sig)
      fmt.Println("valid:", ed25519.Verify(pub, msg, sig))
    end
end
