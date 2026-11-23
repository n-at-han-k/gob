require "bytes"
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
      buf = nil
      buf.WriteString("one ")
      buf.WriteString("two ")
      fmt.Fprintf(buf, "three=%d", 3)
      fmt.Println("buffer:", buf.String())
    end
end
