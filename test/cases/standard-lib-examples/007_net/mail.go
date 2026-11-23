package main

import (
	"fmt"      // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"io"       // https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
	"log"      // https://pkg.go.dev/log — Package log implements a simple logging package.
	"net/mail" // https://pkg.go.dev/net/mail — Package mail implements parsing of mail messages.
	"strings"  // https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
)

// net/mail parses RFC 5322 messages and addresses. It doesn't send —
// see net/smtp for that.
func runMail() {
	raw := "From: Alice <alice@example.com>\r\n" +
		"To: Bob <bob@example.org>, carol@example.net\r\n" +
		"Subject: hi\r\n" +
		"Date: Mon, 01 Jan 2024 09:00:00 +0000\r\n" +
		"\r\n" +
		"hello there\r\n"

	msg, err := mail.ReadMessage(strings.NewReader(raw))
	if err != nil {
		log.Fatal(err)
	}

	from, _ := mail.ParseAddress(msg.Header.Get("From"))
	to, _ := mail.ParseAddressList(msg.Header.Get("To"))
	fmt.Println("from:   ", from)
	fmt.Println("to:     ", to)
	fmt.Println("subject:", msg.Header.Get("Subject"))

	body, _ := io.ReadAll(msg.Body)
	fmt.Print("body:   ", string(body))
}
