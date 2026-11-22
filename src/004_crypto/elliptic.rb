# https://pkg.go.dev/crypto/elliptic — Package elliptic implements the standard NIST P-224, P-256, P-384, and P-521 elliptic curves over prime fields.
require "crypto/elliptic"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # The elliptic package now mostly exposes the NIST curves used by
    # crypto/ecdsa and crypto/ecdh. Direct point arithmetic is deprecated.
    def self.runElliptic
      [
        elliptic.P224(),
        elliptic.P256(),
        elliptic.P384(),
        elliptic.P521()
      ].each do |_, c|
        p = c.Params()
        fmt.Printf("%-6s bits=%d Gx=0x%x...\n", p.Name, p.BitSize, p.Gx.Bytes()[...4])
      end
    end
end
