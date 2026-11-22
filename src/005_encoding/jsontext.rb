# https://pkg.go.dev/encoding/json/jsontext — Package jsontext implements syntactic processing of JSON (RFC 4627/7159/7493/8259/8785).
require "encoding/json/jsontext"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
require "io"
# https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
require "strings"
module Main
  private

    # Requires GOEXPERIMENT=jsonv2 (Go 1.26). Run this demo with:
    #   GOEXPERIMENT=jsonv2 go run . jsontext
    #
    # jsontext operates at the token level — it doesn't map to Go types
    # like encoding/json does. Handy for validating, streaming, or
    # transforming JSON without allocating a full value tree.
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
