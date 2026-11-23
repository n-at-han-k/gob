package main

import (
	"fmt"      // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"net/smtp" // https://pkg.go.dev/net/smtp — Package smtp implements the Simple Mail Transfer Protocol as defined in RFC 5321.
)

// smtp is the SMTP client — it dials a real mail server and speaks the
// protocol. We don't do that here (no server, no auth), so we just
// build the objects and print what smtp.SendMail would use.
func runSMTP() {
	auth := smtp.PlainAuth("", "alice@example.com", "hunter2", "smtp.example.com")
	from := "alice@example.com"
	to := []string{"bob@example.org"}
	body := []byte("Subject: hello\r\n\r\nsent by net/smtp\r\n")

	fmt.Printf("auth:  %T\n", auth)
	fmt.Println("from:  ", from)
	fmt.Println("to:    ", to)
	fmt.Printf("body:\n%s", body)
	fmt.Println("(smtp.SendMail would dial smtp.example.com:25 and deliver this)")
}
