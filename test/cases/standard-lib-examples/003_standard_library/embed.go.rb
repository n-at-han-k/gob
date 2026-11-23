# https://pkg.go.dev/embed — Package embed provides access to files embedded in the running Go program. -- imported as _
require "embed"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  # //go:embed reads a file at build time into the variable.
  # The greeting.txt file is created alongside this main.go.
  #
  # go:embed greeting.txt
  greeting = ""

  private

    def self.runEmbed
      fmt.Print(greeting)
    end
end
