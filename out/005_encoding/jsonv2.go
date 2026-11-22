package main

import (
	"encoding/json/v2"
	"fmt"
	"log"
)

type V2article struct {
	Title any
	Tags  any
}

func runJSONv2() {
	a := V2article.new(map[any]any{Title: "Learning Go", Tags: []any{"go", "v2"}})
	data, err := json.Marshal(a)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("marshalled:", string(data))
	back := nil
	err = json.Unmarshal(data, back)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("parsed: %+v\n", back)
}
