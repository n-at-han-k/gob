package main

import (
	"bufio"   
	"fmt"     
	"strings" 
)

func runBufio() {

	input := "first line\nsecond line\nthird line\n"
	sc := bufio.NewScanner(strings.NewReader(input))
	for sc.Scan() {
		fmt.Println("line:", sc.Text())
	}

	sc = bufio.NewScanner(strings.NewReader("the quick brown fox"))
	sc.Split(bufio.ScanWords)
	for sc.Scan() {
		fmt.Println("word:", sc.Text())
	}

	var sb strings.Builder
	bw := bufio.NewWriter(&sb)
	bw.WriteString("buffered ")
	bw.WriteString("write")
	bw.Flush()
	fmt.Println(sb.String())
}
