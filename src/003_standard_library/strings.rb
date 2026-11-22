# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
require "strings"
module Main
  private

    def self.runStrings
      s = "The quick brown fox jumps over the lazy dog"
      fmt.Println("Upper:      ", strings.ToUpper(s))
      fmt.Println("Contains:   ", strings.Contains(s, "fox"))
      fmt.Println("Count 'o':  ", strings.Count(s, "o"))
      fmt.Println("Fields:     ", strings.Fields(s))
      fmt.Println("Split:      ", strings.Split(s, " "))
      fmt.Println("Replace:    ", strings.Replace(s, "fox", "cat", 1))
      fmt.Println("HasPrefix:  ", strings.HasPrefix(s, "The"))
      fmt.Println("TrimSpace:  ", strings.TrimSpace("   pad   "))
      # Builder concatenates efficiently without repeated allocations.
      b = nil

      %w[one two three].each do |_, w|
        b.WriteString(w)
        b.WriteByte(" ")
      end

      fmt.Println("Builder:    ", strings.TrimSpace(b.String()))
    end
end
