require "bufio"
require "fmt"
require "strings"
module Main
  private

    def self.runBufio
      input = "first line\nsecond line\nthird line\n"
      sc = bufio.NewScanner(strings.NewReader(input))
      fmt.Println("line:", sc.Text()) while sc.Scan()
      sc = bufio.NewScanner(strings.NewReader("the quick brown fox"))
      sc.Split(bufio.ScanWords)
      fmt.Println("word:", sc.Text()) while sc.Scan()
      sb = nil
      bw = bufio.NewWriter(sb)
      bw.WriteString("buffered ")
      bw.WriteString("write")
      bw.Flush()
      fmt.Println(sb.String())
    end
end
