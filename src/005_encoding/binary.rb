# https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
require "bytes"
# https://pkg.go.dev/encoding/binary — Package binary implements simple translation between numbers and byte sequences and encoding/decoding of varints.
require "encoding/binary"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    def self.runBinary
      # Fixed-size numeric encoding in a chosen byte order.
      buf = nil
      binary.Write(buf, binary.BigEndian, uint32(0xdeadbeef))
      binary.Write(buf, binary.LittleEndian, uint16(0x1234))
      fmt.Printf("bytes: %x\n", buf.Bytes())
      # Read them back in the same order.
      a = 0
      b = 0
      err = binary.Read(buf, binary.BigEndian, a)

      if err != nil
        log.Fatal(err)
      end

      binary.Read(buf, binary.LittleEndian, b)
      fmt.Printf("a=%#x b=%#x\n", a, b)
      # Varints are variable-length integer encodings — smaller values
      # take fewer bytes. Great for wire formats.
      vbuf = nil
      n = binary.PutVarint(vbuf, -12_345)
      fmt.Printf("varint(-12345) = %x (%d bytes)\n", vbuf[...n], n)
      v, _ = binary.Varint(vbuf[...n])
      fmt.Println("decoded:", v)
    end
end
