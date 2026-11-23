package main

import (
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"path"          // https://pkg.go.dev/path — Package path implements utility routines for manipulating slash-separated paths.
	"path/filepath" // https://pkg.go.dev/path/filepath — Package filepath implements utility routines for manipulating filename paths in an OS-aware way.
)

func runPath() {
	// package path handles slash-separated (URL-style) paths only.
	fmt.Println("Join:  ", path.Join("a", "b", "..", "c"))
	fmt.Println("Base:  ", path.Base("/x/y/z.txt"))
	fmt.Println("Dir:   ", path.Dir("/x/y/z.txt"))
	fmt.Println("Ext:   ", path.Ext("archive.tar.gz"))
	fmt.Println("Match: ", func() bool { m, _ := path.Match("*.go", "main.go"); return m }())

	// package filepath is OS-aware (uses \ on Windows, / elsewhere).
	fmt.Println("filepath.Join:", filepath.Join("dir", "sub", "file.txt"))
	abs, _ := filepath.Abs("main.go")
	fmt.Println("Abs:         ", abs)
}
