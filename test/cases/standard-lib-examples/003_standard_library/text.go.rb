# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/text/tabwriter — Package tabwriter implements a write filter that translates tabbed columns into properly aligned text.
require "text/tabwriter"
# https://pkg.go.dev/text/template — Package template (text/template) implements data-driven templates for generating text output.
require "text/template"
module Main
  private

    # text/template renders arbitrary text; text/tabwriter aligns columns.
    def self.runText
      tmpl = "Hello {{.Name}}!\n{{range .Tasks}}  - {{.}}\n{{end}}"
      t = template.Must(template.New("greet").Parse(tmpl))

      t.Execute(
        os.Stdout,
        {
          "Name" => "Nathan",
          "Tasks" => ["learn Go", "write examples", "ship it"]
        }
      )

      # Tabwriter aligns columns separated by \t.
      tw = tabwriter.NewWriter(os.Stdout, 0, 0, 2, " ", 0)

      _, err =
        tw.Write("Name\tAge\tRole\napple\t3\tfruit\nblue\t42\tcolour\n".bytes)

      if err != nil
        log.Fatal(err)
      end

      tw.Flush()
    end
end
