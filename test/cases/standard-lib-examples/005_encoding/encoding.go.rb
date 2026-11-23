require "encoding"
require "fmt"
module Main
  class Colour
    attr_accessor :R
    attr_accessor :G
    attr_accessor :B

    def MarshalText
      return fmt.Appendf(nil, "#%02x%02x%02x", this.R, this.G, this.B), nil
    end

    def UnmarshalText(text)
      _, err = fmt.Sscanf(string(text), "#%02x%02x%02x", this.R, this.G, this.B)

      return err
    end
  end

  private

    def self.runEncoding
      m = Colour.new(255, 128, 0)
      txt, _ = m.MarshalText()
      fmt.Printf("marshalled: %s\n", txt)
      back = nil
      u = back
      _ = u.UnmarshalText("#0080ff".bytes)
      fmt.Printf("parsed:     %+v\n", back)
    end
end
