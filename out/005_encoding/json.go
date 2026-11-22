package main

import (
	"encoding/json"
	"fmt"
	"log"
	"strings"
)

type Article struct {
	Title    any
	Views    any
	Tags     any
	internal any
}

func runJSON() {
	a := Article.new(map[any]any{Title: "Learning Go", Views: 12, Tags: []any{"go", "stdlib"}})
	data, err := json.Marshal(a)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("compact:", string(data))
	pretty, _ := json.MarshalIndent(a, "", "  ")
	fmt.Println(string(pretty))
	back := nil
	json.Unmarshal(data, back)
	fmt.Printf("parsed: %+v\n", back)
	stream := "{\"n\":1}{\"n\":2}{\"n\":3}"
	dec := json.NewDecoder(strings.NewReader(stream))
	for dec.More() {
		v := nil
		dec.Decode(v)
		fmt.Println("stream:", v)
	}
}
