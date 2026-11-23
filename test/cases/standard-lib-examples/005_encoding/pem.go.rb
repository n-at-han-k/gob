require "encoding/pem"
require "fmt"
require "os"
module Main
  private

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
      encoded = pem.EncodeToMemory(block)
      got, rest = pem.Decode(encoded)
      fmt.Printf("type=%s bytes=%q leftover=%d\n", got.Type, got.Bytes, len(rest))
    end
end
