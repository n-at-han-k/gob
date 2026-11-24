package main

import (
	"log"            
	"os"             
	"text/tabwriter" 
	"text/template"  
)

func runText() {
	const tmpl = `Hello {{.Name}}!
{{range .Tasks}}  - {{.}}
{{end}}`
	t := template.Must(template.New("greet").Parse(tmpl))
	t.Execute(os.Stdout, map[string]any{
		"Name":  "Nathan",
		"Tasks": []string{"learn Go", "write examples", "ship it"},
	})

	tw := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	if _, err := tw.Write([]byte("Name\tAge\tRole\napple\t3\tfruit\nblue\t42\tcolour\n")); err != nil {
		log.Fatal(err)
	}
	tw.Flush()
}
