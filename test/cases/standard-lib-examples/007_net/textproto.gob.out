package main

import (
	"bufio"
	"fmt"
	"log"
	"net/textproto"
	"strings"
)

func runTextproto() {
	raw := "Host: example.com\r\n" + "Content-Type: text/plain;\r\n charset=utf-8\r\n" + "X-Trace: abc\r\n" + "\r\n"
	r := textproto.NewReader(bufio.NewReader(strings.NewReader(raw)))
	hdr, err := r.ReadMIMEHeader()
	if err != nil {
		log.Fatal(err)
	}
	for k, v := range hdr {
		fmt.Printf("  %s: %v\n", k, v)
	}
	fmt.Println("canonical:", textproto.CanonicalMIMEHeaderKey("x-trace"))
}
