package main

import (
	"fmt"
	"net/smtp"
)

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
