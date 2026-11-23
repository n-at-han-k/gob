require "encoding/json/jsontext"
require "fmt"
require "io"
require "strings"
module Main
  private

    def self.runJSONText
      src = "{\"name\":\"Nathan\",\"tags\":[\"go\",\"stdlib\"],\"count\":3}"
      dec = jsontext.NewDecoder(strings.NewReader(src))

      loop do
        tok, err = dec.ReadToken()

        if err == io.EOF
          break
        end

        if err != nil
          fmt.Println("err:", err)

          return
        end

        fmt.Printf("kind=%c value=%s\n", tok.Kind(), tok.String())
      end
    end
end
