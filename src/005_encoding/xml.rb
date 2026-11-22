# https://pkg.go.dev/encoding/xml — Package xml implements a simple XML 1.0 parser that understands XML namespaces.
require "encoding/xml"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  class Book
    attr_accessor :XMLName # xml:"book"
    attr_accessor :Title # xml:"title"
    attr_accessor :Author # xml:"author,attr"
    attr_accessor :Tags # xml:"tags>tag"
  end

  private

    def self.runXML
      b = Book.new(Title: "Learning Go", Author: "Nathan", Tags: %w[go stdlib])
      # MarshalIndent pretty-prints — Marshal returns a single line.
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
