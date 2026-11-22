# https://pkg.go.dev/encoding/json — Package json implements encoding and decoding of JSON as defined in RFC 7159.
require "encoding/json"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
require "strings"
module Main
  class Article
    attr_accessor :Title # json:"title"
    attr_accessor :Views # json:"views"
    attr_accessor :Tags # json:"tags,omitempty"
    attr_accessor :internal # unexported — always skipped
  end

  private

    def self.runJSON
      a = Article.new(Title: "Learning Go", Views: 12, Tags: %w[go stdlib])
      # Marshal a value.
      data, err = json.Marshal(a)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("compact:", string(data))
      # MarshalIndent pretty-prints.
      pretty, _ = json.MarshalIndent(a, "", "  ")
      fmt.Println(string(pretty))
      # Unmarshal into a struct or into map[string]any for schema-free data.
      back = nil
      json.Unmarshal(data, back)
      fmt.Printf("parsed: %+v\n", back)
      # Streaming decoder over multiple JSON values.
      stream = "{\"n\":1}{\"n\":2}{\"n\":3}"
      dec = json.NewDecoder(strings.NewReader(stream))

      while dec.More()
        v = nil
        dec.Decode(v)
        fmt.Println("stream:", v)
      end
    end
end
