# https://pkg.go.dev/crypto — Package crypto collects common cryptographic constants.
require "crypto"
# https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
require "crypto/rand"
# https://pkg.go.dev/crypto/rsa — Package rsa implements RSA encryption as specified in PKCS #1 and RFC 8017.
require "crypto/rsa"
# https://pkg.go.dev/crypto/sha256 — Package sha256 implements the SHA224 and SHA256 hash algorithms.
require "crypto/sha256"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # RSA signing example (PSS is preferred over PKCS#1 v1.5 for new code).
    def self.runRSA
      priv, err = rsa.GenerateKey(rand.Reader, 2048)

      if err != nil
        log.Fatal(err)
      end

      digest = sha256.Sum256("sign me".bytes)
      sig, err = rsa.SignPSS(rand.Reader, priv, crypto.SHA256, digest, nil)

      if err != nil
        log.Fatal(err)
      end

      err = rsa.VerifyPSS(priv.PublicKey, crypto.SHA256, digest, sig, nil)
      fmt.Printf("signature (%d bytes)\n", len(sig))
      fmt.Println("verify err:", err)
      # nil means success
    end
end
