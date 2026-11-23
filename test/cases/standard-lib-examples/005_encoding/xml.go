package main

import (
	"encoding/xml" // https://pkg.go.dev/encoding/xml — Package xml implements a simple XML 1.0 parser that understands XML namespaces.
	"fmt"          // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"          // https://pkg.go.dev/log — Package log implements a simple logging package.
)

type book struct {
	XMLName xml.Name `xml:"book"`
	Title   string   `xml:"title"`
	Author  string   `xml:"author,attr"`
	Tags    []string `xml:"tags>tag"`
}

func runXML() {
	b := book{Title: "Learning Go", Author: "Nathan", Tags: []string{"go", "stdlib"}}

	// MarshalIndent pretty-prints — Marshal returns a single line.
	data, err := xml.MarshalIndent(b, "", "  ")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(xml.Header + string(data))

	var back book
	if err := xml.Unmarshal(data, &back); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("parsed: %+v\n", back)
}
