require "bufio"
require "fmt"
require "strings"

module Main

    # ()
    def runBufio
      input = "first line\nsecond line\nthird line\n"
      sc = bufio.NewScanner(strings.NewReader(input))
      while sc.Scan()
        fmt.Println("line:", sc.Text())
      end
      sc = bufio.NewScanner(strings.NewReader("the quick brown fox"))
      sc.Split(bufio.ScanWords)
      while sc.Scan()
        fmt.Println("word:", sc.Text())
      end
      sb = nil
      bw = bufio.NewWriter(sb)
      bw.WriteString("buffered ")
      bw.WriteString("write")
      bw.Flush()
      fmt.Println(sb.String())
    end
end
