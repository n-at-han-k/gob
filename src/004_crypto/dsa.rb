# https://pkg.go.dev/crypto/dsa — Package dsa implements the Digital Signature Algorithm as defined in FIPS 186-3.
require "crypto/dsa"
# https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
require "crypto/rand"
# https://pkg.go.dev/crypto/sha256 — Package sha256 implements the SHA224 and SHA256 hash algorithms.
require "crypto/sha256"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # DSA is legacy; prefer ECDSA or Ed25519 for new signatures.
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
