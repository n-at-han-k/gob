require "fmt"
require "html"
require "html/template"
require "os"
module Main
  private

    def self.runHTML
      raw = "<script>alert(\"xss\")</script>"
      fmt.Println(html.EscapeString(raw))

      tmpl =
        template.Must(template.New("t").Parse("<p>Hello {{.Name}}! Comment: {{.Body}}</p>" + "\n"))

      tmpl.Execute(os.Stdout, { "Name" => "Nathan", "Body" => raw })
    end
end
