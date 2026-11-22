# https://pkg.go.dev/crypto/rc4 — Package rc4 implements RC4 encryption.
require "crypto/rc4"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # RC4 is broken; the package exists purely for interop with legacy
    # protocols. Do not use it for new code.
    def self.runRC4
      c, err = rc4.NewCipher("weakkey".bytes)

      if err != nil
        log.Fatal(err)
      end

      pt = "legacy data".bytes
      ct = make([], len(pt))
      c.XORKeyStream(ct, pt)
      # Encrypt again with a fresh cipher to decrypt (RC4 is XOR-based).
      c2, _ = rc4.NewCipher("weakkey".bytes)
      out = make([], len(ct))
      c2.XORKeyStream(out, ct)
      fmt.Printf("ct: %x\npt: %s\n", ct, out)
    end
end
