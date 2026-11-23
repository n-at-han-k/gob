package main

import (
	"bufio"   // https://pkg.go.dev/bufio — Package bufio implements buffered I/O.
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"strings" // https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
)

func runBufio() {
	// Scanner reads input line by line (or word by word, etc.).
	input := "first line\nsecond line\nthird line\n"
	sc := bufio.NewScanner(strings.NewReader(input))
	for sc.Scan() {
		fmt.Println("line:", sc.Text())
	}

	// Word scanning splits on whitespace.
	sc = bufio.NewScanner(strings.NewReader("the quick brown fox"))
	sc.Split(bufio.ScanWords)
	for sc.Scan() {
		fmt.Println("word:", sc.Text())
	}

	// Writer buffers output until Flush is called.
	var sb strings.Builder
	bw := bufio.NewWriter(&sb)
	bw.WriteString("buffered ")
	bw.WriteString("write")
	bw.Flush()
	fmt.Println(sb.String())
}
