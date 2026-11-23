package main

import (
	"fmt"  // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"  // https://pkg.go.dev/log — Package log implements a simple logging package.
	"mime" // https://pkg.go.dev/mime — Package mime implements parts of the MIME spec.
)

func runMime() {
	// TypeByExtension looks up a MIME type from a file extension.
	fmt.Println(".html:", mime.TypeByExtension(".html"))
	fmt.Println(".json:", mime.TypeByExtension(".json"))

	// ParseMediaType splits a header value into type + parameters.
	mt, params, err := mime.ParseMediaType(`text/plain; charset="utf-8"`)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("type:", mt, "params:", params)

	// FormatMediaType builds one back the other way.
	fmt.Println(mime.FormatMediaType("text/html", map[string]string{"charset": "utf-8"}))
}
