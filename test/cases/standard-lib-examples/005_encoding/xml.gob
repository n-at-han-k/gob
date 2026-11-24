require "encoding/xml"
require "fmt"
require "log"

module Main
  class Book
    attr_accessor :XMLName
    attr_accessor :Title
    attr_accessor :Author
    attr_accessor :Tags
  end


    # ()
    def runXML
      b = Book.new(Title: "Learning Go", Author: "Nathan", Tags: %w[go stdlib])
      data, err = xml.MarshalIndent(b, "", "  ")

      if err != nil
        log.Fatal(err)
      end

      fmt.Println(xml.Header + string(data))
      back = nil
      err = xml.Unmarshal(data, back)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("parsed: %+v\n", back)
    end
end
