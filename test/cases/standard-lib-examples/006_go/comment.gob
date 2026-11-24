require "fmt"
require "go/doc/comment"

module Main

    # ()
    def runComment
      src =
        "Package widget draws widgets.\n\n# Overview\n\nWidgets come in three sizes:\n  - small\n  - medium\n  - large\n\nSee [example.com] for details.\n\n[example.com]: https://example.com\n"

      p = nil
      doc = p.Parse(src)
      pr = nil
      fmt.Print(string(pr.Markdown(doc)))
    end
end
