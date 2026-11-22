package main

import (
	"fmt"
	"go/format"
	"log"
)

func runFormat() {
	src := "package p\nfunc   Add(a,b int)int{return a+b}\n".bytes
	pretty, err := format.Source(src)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("---before---")
	fmt.Print(string(src))
	fmt.Println("---after----")
	fmt.Print(string(pretty))
}
