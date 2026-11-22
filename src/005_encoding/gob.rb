# https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
require "bytes"
# https://pkg.go.dev/encoding/gob — Package gob manages streams of gobs — binary values exchanged between an Encoder (transmitter) and a Decoder (receiver).
require "encoding/gob"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  # gob is a Go-native binary format that carries type info with the value,
  # so the decoder knows how to reconstruct concrete types. Ideal for RPC
  # between Go processes; not portable to other languages.
  class Message
    attr_accessor :Kind
    attr_accessor :Body
  end

  private

    def self.runGob
      buf = nil
      enc = gob.NewEncoder(buf)
      err = enc.Encode(Message.new(Kind: "primes", Body: [2, 3, 5, 7, 11]))

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("encoded %d bytes\n", buf.Len())
      back = nil
      err = gob.NewDecoder(buf).Decode(back)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("decoded: %+v\n", back)
    end
end
