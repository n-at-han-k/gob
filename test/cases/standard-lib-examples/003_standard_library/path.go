package main

import (
	"fmt"           
	"path"          
	"path/filepath" 
)

func runPath() {

	fmt.Println("Join:  ", path.Join("a", "b", "..", "c"))
	fmt.Println("Base:  ", path.Base("/x/y/z.txt"))
	fmt.Println("Dir:   ", path.Dir("/x/y/z.txt"))
	fmt.Println("Ext:   ", path.Ext("archive.tar.gz"))
	fmt.Println("Match: ", func() bool { m, _ := path.Match("*.go", "main.go"); return m }())

	fmt.Println("filepath.Join:", filepath.Join("dir", "sub", "file.txt"))
	abs, _ := filepath.Abs("main.go")
	fmt.Println("Abs:         ", abs)
}
