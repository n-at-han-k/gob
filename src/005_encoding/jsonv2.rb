# https://pkg.go.dev/encoding/json/v2 — Package json implements semantic processing of JSON as specified in RFC 8259. -- imported as json
require "encoding/json/v2"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  # Requires GOEXPERIMENT=jsonv2 (Go 1.26). Run this demo with:
  #   GOEXPERIMENT=jsonv2 go run . jsonv2
  #
  # json/v2 is the redesigned JSON package. Highlights vs. v1:
  #   - Marshal/Unmarshal take an io.Writer/Reader by default
  #     (MarshalWrite / UnmarshalRead), plus byte-slice helpers.
  #   - Options-based API instead of struct-tag flags for everything.
  #   - Cleaner separation from jsontext, which owns syntax.
  class V2article
    attr_accessor :Title # json:"title"
    attr_accessor :Tags # json:"tags,omitzero"
  end

  private

    def self.runJSONv2
      a = V2article.new(Title: "Learning Go", Tags: %w[go v2])
      data, err = json.Marshal(a)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("marshalled:", string(data))
      back = nil
      err = json.Unmarshal(data, back)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("parsed: %+v\n", back)
    end
end
