package main

import (
	"encoding/json/jsontext" 
	"fmt"                    
	"io"                     
	"strings"                
)

func runJSONText() {
	src := `{"name":"Nathan","tags":["go","stdlib"],"count":3}`
	dec := jsontext.NewDecoder(strings.NewReader(src))
	for {
		tok, err := dec.ReadToken()
		if err == io.EOF {
			break
		}
		if err != nil {
			fmt.Println("err:", err)
			return
		}
		fmt.Printf("kind=%c value=%s\n", tok.Kind(), tok.String())
	}
}
