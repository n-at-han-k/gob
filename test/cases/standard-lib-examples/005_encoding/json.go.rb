require "encoding/json"
require "fmt"
require "log"
require "strings"
module Main
  class Article
    attr_accessor :Title
    attr_accessor :Views
    attr_accessor :Tags
    attr_accessor :internal
  end

  private

    def self.runJSON
      a = Article.new(Title: "Learning Go", Views: 12, Tags: %w[go stdlib])
      data, err = json.Marshal(a)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("compact:", string(data))
      pretty, _ = json.MarshalIndent(a, "", "  ")
      fmt.Println(string(pretty))
      back = nil
      json.Unmarshal(data, back)
      fmt.Printf("parsed: %+v\n", back)
      stream = "{\"n\":1}{\"n\":2}{\"n\":3}"
      dec = json.NewDecoder(strings.NewReader(stream))

      while dec.More()
        v = nil
        dec.Decode(v)
        fmt.Println("stream:", v)
      end
    end
end
