# https://pkg.go.dev/bufio — Package bufio implements buffered I/O.
require "bufio"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
require "strings"
module Main
  private

    def self.runBufio
      # Scanner reads input line by line (or word by word, etc.).
      input = "first line\nsecond line\nthird line\n"
      sc = bufio.NewScanner(strings.NewReader(input))
      fmt.Println("line:", sc.Text()) while sc.Scan()
      # Word scanning splits on whitespace.
      sc = bufio.NewScanner(strings.NewReader("the quick brown fox"))
      sc.Split(bufio.ScanWords)
      fmt.Println("word:", sc.Text()) while sc.Scan()
      # Writer buffers output until Flush is called.
      sb = nil
      bw = bufio.NewWriter(sb)
      bw.WriteString("buffered ")
      bw.WriteString("write")
      bw.Flush()
      fmt.Println(sb.String())
    end
end
