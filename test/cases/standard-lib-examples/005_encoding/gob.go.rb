require "bytes"
require "encoding/gob"
require "fmt"
require "log"
module Main
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
