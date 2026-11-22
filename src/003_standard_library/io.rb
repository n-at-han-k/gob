# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
require "io"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
require "strings"
module Main
  private

    def self.runIO
      # io.Copy streams from any Reader to any Writer.
      src = strings.NewReader("streamed to stdout\n")
      io.Copy(os.Stdout, src)
      # io.ReadAll drains a reader into memory.
      all, _ = io.ReadAll(strings.NewReader("read all at once"))
      fmt.Println(string(all))
      # io.MultiWriter fans a single write out to many writers.
      sb1 = nil
      mw = io.MultiWriter(sb1, sb2)
      fmt.Fprintln(mw, "goes to both")
      fmt.Println("sb1:", sb1.String())
      fmt.Println("sb2:", sb2.String())
      # io.LimitReader wraps a reader to stop after N bytes.
      limited = io.LimitReader(strings.NewReader("abcdefghij"), 4)
      buf, _ = io.ReadAll(limited)
      fmt.Println("limited:", string(buf))
    end
end
