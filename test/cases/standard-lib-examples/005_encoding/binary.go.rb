require "bytes"
require "encoding/binary"
require "fmt"
require "log"
module Main
  private

    def self.runBinary
      buf = nil
      binary.Write(buf, binary.BigEndian, uint32(0xdeadbeef))
      binary.Write(buf, binary.LittleEndian, uint16(0x1234))
      fmt.Printf("bytes: %x\n", buf.Bytes())
      a = 0
      b = 0
      err = binary.Read(buf, binary.BigEndian, a)

      if err != nil
        log.Fatal(err)
      end

      binary.Read(buf, binary.LittleEndian, b)
      fmt.Printf("a=%#x b=%#x\n", a, b)
      vbuf = nil
      n = binary.PutVarint(vbuf, -12_345)
      fmt.Printf("varint(-12345) = %x (%d bytes)\n", vbuf[...n], n)
      v, _ = binary.Varint(vbuf[...n])
      fmt.Println("decoded:", v)
    end
end
