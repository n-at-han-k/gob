# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/html — Package html provides functions for escaping and unescaping HTML text.
require "html"
# https://pkg.go.dev/html/template — Package template (html/template) implements data-driven templates for generating HTML output safe against code injection.
require "html/template"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
module Main
  private

    def self.runHTML
      # html.EscapeString neutralises HTML-special characters.
      raw = "<script>alert(\"xss\")</script>"
      fmt.Println(html.EscapeString(raw))

      # html/template auto-escapes template values based on context.
      tmpl =
        template.Must(template.New("t").Parse("<p>Hello {{.Name}}! Comment: {{.Body}}</p>" + "\n"))

      tmpl.Execute(os.Stdout, { "Name" => "Nathan", "Body" => raw })
    end
end
