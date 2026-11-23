require "crypto/elliptic"
require "fmt"
module Main
  private

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
