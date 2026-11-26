package main

import (
	_ "embed" 
	"fmt"     
)

var greeting string

func runEmbed() {
	fmt.Print(greeting)
}
