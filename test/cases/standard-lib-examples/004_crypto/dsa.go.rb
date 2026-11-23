require "crypto/dsa"
require "crypto/rand"
require "crypto/sha256"
require "fmt"
require "log"
module Main
  private

    def self.runDSA
      params = nil
      err = dsa.GenerateParameters(params, rand.Reader, dsa.L1024N160)

      if err != nil
        log.Fatal(err)
      end

      priv = PrivateKey.new(PublicKey: PublicKey.new(Parameters: params))
      err = dsa.GenerateKey(priv, rand.Reader)

      if err != nil
        log.Fatal(err)
      end

      digest = sha256.Sum256("hello".bytes)
      r, s, err = dsa.Sign(rand.Reader, priv, digest)

      if err != nil
        log.Fatal(err)
      end

      ok = dsa.Verify(priv.PublicKey, digest, r, s)
      fmt.Println("signature valid:", ok)
    end
end
