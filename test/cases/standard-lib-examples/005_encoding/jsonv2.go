package main

import (
	json "encoding/json/v2" // https://pkg.go.dev/encoding/json/v2 — Package json implements semantic processing of JSON as specified in RFC 8259.
	"fmt"                   // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"                   // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// Requires GOEXPERIMENT=jsonv2 (Go 1.26). Run this demo with:
//   GOEXPERIMENT=jsonv2 go run . jsonv2
//
// json/v2 is the redesigned JSON package. Highlights vs. v1:
//   - Marshal/Unmarshal take an io.Writer/Reader by default
//     (MarshalWrite / UnmarshalRead), plus byte-slice helpers.
//   - Options-based API instead of struct-tag flags for everything.
//   - Cleaner separation from jsontext, which owns syntax.
type v2article struct {
	Title string   `json:"title"`
	Tags  []string `json:"tags,omitzero"`
}

func runJSONv2() {
	a := v2article{Title: "Learning Go", Tags: []string{"go", "v2"}}

	data, err := json.Marshal(a)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("marshalled:", string(data))

	var back v2article
	if err := json.Unmarshal(data, &back); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("parsed: %+v\n", back)
}
