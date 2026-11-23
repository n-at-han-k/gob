require "encoding/json/v2"
require "fmt"
require "log"
module Main
  class V2article
    attr_accessor :Title
    attr_accessor :Tags
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
