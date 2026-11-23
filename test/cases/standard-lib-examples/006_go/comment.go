package main

import (
	"fmt"             // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/doc/comment" // https://pkg.go.dev/go/doc/comment — Package comment implements parsing and reformatting of Go doc comments.
)

// comment gives you a real parser for the mini-markdown dialect used in
// doc comments — headings, lists, links, code blocks — then can print
// the result back out as text, HTML or Markdown.
func runComment() {
	src := `Package widget draws widgets.

# Overview

Widgets come in three sizes:
  - small
  - medium
  - large

See [example.com] for details.

[example.com]: https://example.com
`
	var p comment.Parser
	doc := p.Parse(src)

	// Re-emit as Markdown.
	var pr comment.Printer
	fmt.Print(string(pr.Markdown(doc)))
}
