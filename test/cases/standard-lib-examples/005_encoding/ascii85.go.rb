require "encoding/ascii85"
require "fmt"
module Main
  private

    def self.runAscii85
      src = "hello ascii85".bytes
      dst = make([], ascii85.MaxEncodedLen(len(src)))
      n = ascii85.Encode(dst, src)
      dst = dst[...n]
      fmt.Printf("encoded: %s\n", dst)
      back = make([], len(src))
      ndst, _, err = ascii85.Decode(back, dst, true)

      if err != nil
        fmt.Println("decode err:", err)

        return
      end

      fmt.Printf("decoded: %s\n", back[...ndst])
    end
end
