require "log"
require "os"
require "text/tabwriter"
require "text/template"
module Main
  private

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

      tw = tabwriter.NewWriter(os.Stdout, 0, 0, 2, " ", 0)

      _, err =
        tw.Write("Name\tAge\tRole\napple\t3\tfruit\nblue\t42\tcolour\n".bytes)

      if err != nil
        log.Fatal(err)
      end

      tw.Flush()
    end
end
