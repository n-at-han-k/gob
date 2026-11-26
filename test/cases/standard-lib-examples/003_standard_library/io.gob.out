package main

import (
	"fmt"
	"io"
	"os"
	"strings"
)

func runIO() {
	src := strings.NewReader("streamed to stdout\n")
	io.Copy(os.Stdout, src)
	all, _ := io.ReadAll(strings.NewReader("read all at once"))
	fmt.Println(string(all))
	sb1 := nil
	mw := io.MultiWriter(sb1, sb2)
	fmt.Fprintln(mw, "goes to both")
	fmt.Println("sb1:", sb1.String())
	fmt.Println("sb2:", sb2.String())
	limited := io.LimitReader(strings.NewReader("abcdefghij"), 4)
	buf, _ := io.ReadAll(limited)
	fmt.Println("limited:", string(buf))
}
