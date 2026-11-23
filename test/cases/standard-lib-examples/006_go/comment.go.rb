# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/doc/comment — Package comment implements parsing and reformatting of Go doc comments.
require "go/doc/comment"
module Main
  private

    # comment gives you a real parser for the mini-markdown dialect used in
    # doc comments — headings, lists, links, code blocks — then can print
    # the result back out as text, HTML or Markdown.
    def self.runComment
      src =
        "Package widget draws widgets.\n\n# Overview\n\nWidgets come in three sizes:\n  - small\n  - medium\n  - large\n\nSee [example.com] for details.\n\n[example.com]: https://example.com\n"

      p = nil
      doc = p.Parse(src)
      # Re-emit as Markdown.
      pr = nil
      fmt.Print(string(pr.Markdown(doc)))
    end
end
