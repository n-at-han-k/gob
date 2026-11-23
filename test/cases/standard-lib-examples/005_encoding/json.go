package main

import (
	"encoding/json" // https://pkg.go.dev/encoding/json — Package json implements encoding and decoding of JSON as defined in RFC 7159.
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"           // https://pkg.go.dev/log — Package log implements a simple logging package.
	"strings"       // https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
)

type article struct {
	Title    string   `json:"title"`
	Views    int      `json:"views"`
	Tags     []string `json:"tags,omitempty"`
	internal string   // unexported — always skipped
}

func runJSON() {
	a := article{Title: "Learning Go", Views: 12, Tags: []string{"go", "stdlib"}}

	// Marshal a value.
	data, err := json.Marshal(a)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("compact:", string(data))

	// MarshalIndent pretty-prints.
	pretty, _ := json.MarshalIndent(a, "", "  ")
	fmt.Println(string(pretty))

	// Unmarshal into a struct or into map[string]any for schema-free data.
	var back article
	json.Unmarshal(data, &back)
	fmt.Printf("parsed: %+v\n", back)

	// Streaming decoder over multiple JSON values.
	stream := `{"n":1}{"n":2}{"n":3}`
	dec := json.NewDecoder(strings.NewReader(stream))
	for dec.More() {
		var v map[string]int
		dec.Decode(&v)
		fmt.Println("stream:", v)
	}
}
