# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/format — Package format implements standard formatting of Go source.
require "go/format"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # format is the library behind `gofmt`: take any Go source and return
    # the canonical, formatted version.
    def self.runFormat
      src = "package p\nfunc   Add(a,b int)int{return a+b}\n".bytes
      pretty, err = format.Source(src)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("---before---")
      fmt.Print(string(src))
      fmt.Println("---after----")
      fmt.Print(string(pretty))
    end
end
