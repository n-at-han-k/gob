package main

import (
	"fmt"  
	"log"  
	"mime" 
)

func runMime() {

	fmt.Println(".html:", mime.TypeByExtension(".html"))
	fmt.Println(".json:", mime.TypeByExtension(".json"))

	mt, params, err := mime.ParseMediaType(`text/plain; charset="utf-8"`)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("type:", mt, "params:", params)

	fmt.Println(mime.FormatMediaType("text/html", map[string]string{"charset": "utf-8"}))
}
