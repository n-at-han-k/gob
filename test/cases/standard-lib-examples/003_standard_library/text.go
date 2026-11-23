package main

import (
	"log"            // https://pkg.go.dev/log — Package log implements a simple logging package.
	"os"             // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
	"text/tabwriter" // https://pkg.go.dev/text/tabwriter — Package tabwriter implements a write filter that translates tabbed columns into properly aligned text.
	"text/template"  // https://pkg.go.dev/text/template — Package template (text/template) implements data-driven templates for generating text output.
)

// text/template renders arbitrary text; text/tabwriter aligns columns.
func runText() {
	const tmpl = `Hello {{.Name}}!
{{range .Tasks}}  - {{.}}
{{end}}`
	t := template.Must(template.New("greet").Parse(tmpl))
	t.Execute(os.Stdout, map[string]any{
		"Name":  "Nathan",
		"Tasks": []string{"learn Go", "write examples", "ship it"},
	})

	// Tabwriter aligns columns separated by \t.
	tw := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	if _, err := tw.Write([]byte("Name\tAge\tRole\napple\t3\tfruit\nblue\t42\tcolour\n")); err != nil {
		log.Fatal(err)
	}
	tw.Flush()
}
