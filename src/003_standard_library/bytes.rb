# https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
require "bytes"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    def self.runBytes
      a = "hello world".bytes
      b = "world".bytes
      fmt.Println("Contains:", bytes.Contains(a, b))
      fmt.Println("Index:", bytes.Index(a, b))
      fmt.Println("ToUpper:", string(bytes.ToUpper(a)))
      fmt.Println("Split:", bytes.Split(a, " ".bytes))
      fmt.Println("Replace:", string(bytes.ReplaceAll(a, b, "gopher".bytes)))
      # Buffer is a growable byte buffer implementing io.Reader/Writer.
      buf = nil
      buf.WriteString("one ")
      buf.WriteString("two ")
      fmt.Fprintf(buf, "three=%d", 3)
      fmt.Println("buffer:", buf.String())
    end
end
