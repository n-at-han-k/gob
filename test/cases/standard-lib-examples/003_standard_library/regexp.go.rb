# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/regexp — Package regexp implements regular expression search.
require "regexp"
module Main
  private

    def self.runRegexp
      # MustCompile panics on an invalid pattern — fine for constants.
      re = regexp.MustCompile("(\\w+)@(\\w+\\.\\w+)")
      text = "contact nathan@example.com or admin@test.org"
      fmt.Println("match?     ", re.MatchString(text))
      fmt.Println("first:     ", re.FindString(text))
      fmt.Println("all:       ", re.FindAllString(text, -1))
      fmt.Println("submatches:", re.FindStringSubmatch("nathan@example.com"))
      # ReplaceAllString supports $1, $2 back-references.
      fmt.Println("replaced:  ", re.ReplaceAllString(text, "$1 [at] $2"))
    end
end
