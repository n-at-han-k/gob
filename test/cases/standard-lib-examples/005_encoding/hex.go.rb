require "encoding/hex"
require "fmt"
require "log"
module Main
  private

    def self.runHex
      src = "hello hex".bytes
      encoded = hex.EncodeToString(src)
      fmt.Println("encoded:", encoded)
      back, err = hex.DecodeString(encoded)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("decoded: %s\n", back)
      fmt.Print(hex.Dump(src))
    end
end
