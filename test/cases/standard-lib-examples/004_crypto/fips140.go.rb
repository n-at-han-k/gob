# https://pkg.go.dev/crypto/fips140 — Package fips140 provides information about the FIPS 140-3 Go Cryptographic Module and FIPS 140-3 mode.
require "crypto/fips140"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # Enabled reports whether the process is running in FIPS 140-3 mode
    # (toggled via GODEBUG=fips140=on at build/run time).
    def self.runFIPS140
      fmt.Println("FIPS 140-3 mode enabled:", fips140.Enabled())
      fmt.Println("module version:         ", fips140.Version())
    end
end
