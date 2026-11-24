package main

import (
	"log"
	"os"
	"text/tabwriter"
	"text/template"
)

func runText() {
	tmpl := "Hello {{.Name}}!\n{{range .Tasks}}  - {{.}}\n{{end}}"
	t := template.Must(template.New("greet").Parse(tmpl))
	t.Execute(os.Stdout, map[any]any{"Name": "Nathan", "Tasks": []any{"learn Go", "write examples", "ship it"}})
	tw := tabwriter.NewWriter(os.Stdout, 0, 0, 2, " ", 0)
	_, err := tw.Write("Name\tAge\tRole\napple\t3\tfruit\nblue\t42\tcolour\n".bytes)
	if err != nil {
		log.Fatal(err)
	}
	tw.Flush()
}
