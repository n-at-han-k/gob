# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/path — Package path implements utility routines for manipulating slash-separated paths.
require "path"
# https://pkg.go.dev/path/filepath — Package filepath implements utility routines for manipulating filename paths in an OS-aware way.
require "path/filepath"
module Main
  private

    def self.runPath
      # package path handles slash-separated (URL-style) paths only.
      fmt.Println("Join:  ", path.Join("a", "b", "..", "c"))
      fmt.Println("Base:  ", path.Base("/x/y/z.txt"))
      fmt.Println("Dir:   ", path.Dir("/x/y/z.txt"))
      fmt.Println("Ext:   ", path.Ext("archive.tar.gz"))

      fmt.Println(
        "Match: ",
        lambda do
          m, _ = path.Match("*.go", "main.go")

          return m
        end.call()
      )

      # package filepath is OS-aware (uses \ on Windows, / elsewhere).
      fmt.Println("filepath.Join:", filepath.Join("dir", "sub", "file.txt"))
      abs, _ = filepath.Abs("main.go")
      fmt.Println("Abs:         ", abs)
    end
end
