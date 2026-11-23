require "encoding/base32"
require "fmt"
require "log"
module Main
  private

    def self.runBase32
      src = "hello base32".bytes
      encoded = base32.StdEncoding.EncodeToString(src)
      fmt.Println("std:  ", encoded)
      decoded, err = base32.StdEncoding.DecodeString(encoded)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("decoded: %s\n", decoded)
      fmt.Println("hex:  ", base32.HexEncoding.EncodeToString(src))
    end
end
