require "crypto/fips140"
require "fmt"
module Main
  private

    def self.runFIPS140
      fmt.Println("FIPS 140-3 mode enabled:", fips140.Enabled())
      fmt.Println("module version:         ", fips140.Version())
    end
end
