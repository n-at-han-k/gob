# https://pkg.go.dev/encoding/pem — Package pem implements the PEM data encoding, which originated in Privacy Enhanced Mail.
require "encoding/pem"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
module Main
  private

    # PEM wraps binary data (usually DER) in a base64 envelope with
    # -----BEGIN/END X----- markers. It's what .pem key and cert files use.
    def self.runPEM
      block =
        Block.new(
          Type: "MESSAGE",
          Headers: {
            "Comment" => "learning-go example"
          },
          Bytes: "some binary payload".bytes
        )

      pem.Encode(os.Stdout, block)
      # Round-trip: encode → decode → inspect.
      encoded = pem.EncodeToMemory(block)
      got, rest = pem.Decode(encoded)
      fmt.Printf("type=%s bytes=%q leftover=%d\n", got.Type, got.Bytes, len(rest))
    end
end
