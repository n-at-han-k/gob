require "fmt"
require "go/format"
require "log"
module Main
  private

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
