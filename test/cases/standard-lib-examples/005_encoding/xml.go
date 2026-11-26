package main

import (
	"encoding/xml"
	"fmt"
	"log"
)

type book struct {
	XMLName xml.Name `xml:"book"`
	Title   string   `xml:"title"`
	Author  string   `xml:"author,attr"`
	Tags    []string `xml:"tags>tag"`
}

func runXML() {
	b := book{Title: "Learning Go", Author: "Nathan", Tags: []string{"go", "stdlib"}}

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
