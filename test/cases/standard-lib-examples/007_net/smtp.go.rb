# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/net/smtp — Package smtp implements the Simple Mail Transfer Protocol as defined in RFC 5321.
require "net/smtp"
module Main
  private

    # smtp is the SMTP client — it dials a real mail server and speaks the
    # protocol. We don't do that here (no server, no auth), so we just
    # build the objects and print what smtp.SendMail would use.
    def self.runSMTP
      auth =
        smtp.PlainAuth("", "alice@example.com", "hunter2", "smtp.example.com")

      from = "alice@example.com"
      to = ["bob@example.org"]
      body = "Subject: hello\r\n\r\nsent by net/smtp\r\n".bytes
      fmt.Printf("auth:  %T\n", auth)
      fmt.Println("from:  ", from)
      fmt.Println("to:    ", to)
      fmt.Printf("body:\n%s", body)
      fmt.Println("(smtp.SendMail would dial smtp.example.com:25 and deliver this)")
    end
end
