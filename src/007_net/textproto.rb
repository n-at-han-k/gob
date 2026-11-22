# https://pkg.go.dev/bufio — Package bufio implements buffered I/O.
require "bufio"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/net/textproto — Package textproto implements generic support for text-based request/response protocols in the style of HTTP, NNTP, and SMTP.
require "net/textproto"
# https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
require "strings"
module Main
  private

    # textproto is the shared plumbing behind net/mail, net/smtp and
    # net/http: reading CRLF-terminated lines, parsing MIME-style headers
    # with continuations, and canonicalising header names.
    def self.runTextproto
      raw =
        "Host: example.com\r\n" +
        "Content-Type: text/plain;\r\n charset=utf-8\r\n" + "X-Trace: abc\r\n" +
        "\r\n"

      r = textproto.NewReader(bufio.NewReader(strings.NewReader(raw)))
      hdr, err = r.ReadMIMEHeader()

      if err != nil
        log.Fatal(err)
      end

      hdr.each { |k, v| fmt.Printf("  %s: %v\n", k, v) }
      fmt.Println("canonical:", textproto.CanonicalMIMEHeaderKey("x-trace"))
    end
end
