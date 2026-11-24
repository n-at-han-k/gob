package main

import (
	"fmt"             
	"go/doc/comment" 
)

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

	var pr comment.Printer
	fmt.Print(string(pr.Markdown(doc)))
}
