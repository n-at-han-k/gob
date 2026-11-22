# https://pkg.go.dev/encoding — Package encoding defines interfaces shared by other packages that convert data to and from byte-level and textual representations.
require "encoding"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  # The root encoding package only defines marker interfaces
  # (TextMarshaler/Unmarshaler, BinaryMarshaler/Unmarshaler) that other
  # packages — json, xml, etc. — check for when serialising values.
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
      # Type-assert to the interface to prove the methods are wired up.
      m = Colour.new(255, 128, 0)
      txt, _ = m.MarshalText()
      fmt.Printf("marshalled: %s\n", txt)
      back = nil
      u = back
      _ = u.UnmarshalText("#0080ff".bytes)
      fmt.Printf("parsed:     %+v\n", back)
    end
end
