require "fmt"
require "unicode"
require "unicode/utf8"
module Main
  private

    def self.runUnicode
      "Aa1!  你".each do |_, r|
        fmt.Printf("%q letter=%v digit=%v space=%v\n", r, unicode.IsLetter(r), unicode.IsDigit(r), unicode.IsSpace(r))
      end

      fmt.Println(string(unicode.ToUpper("ß")))
      s = "héllo"
      fmt.Println("bytes:", len(s), "runes:", utf8.RuneCountInString(s))
    end
end
