package main

import (
	"archive/tar" // https://pkg.go.dev/archive/tar — Package tar implements access to tar archives.
	"archive/zip" // https://pkg.go.dev/archive/zip — Package zip provides support for reading and writing ZIP archives.
	"bytes"       // https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
	"fmt"         // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"io"          // https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
	"log"         // https://pkg.go.dev/log — Package log implements a simple logging package.
	"os"          // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
	"strings"     // https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
)

func runArchive() {
	zipDemo()
	tarDemo()
}

func zipDemo() {
	// Create a zip archive on disk.
	f, err := os.Create("example.zip")
	if err != nil {
		log.Fatal(err)
	}
	zw := zip.NewWriter(f)
	w, _ := zw.Create("hello.txt")
	io.Copy(w, strings.NewReader("hello from inside a zip"))
	zw.Close()
	f.Close()

	// Read it back and print each file's contents.
	zr, err := zip.OpenReader("example.zip")
	if err != nil {
		log.Fatal(err)
	}
	defer zr.Close()
	fmt.Println("--- zip ---")
	for _, entry := range zr.File {
		rc, _ := entry.Open()
		body, _ := io.ReadAll(rc)
		rc.Close()
		fmt.Printf("%s: %s\n", entry.Name, body)
	}
}

func tarDemo() {
	// Build a tar archive in memory (writers accept any io.Writer).
	var buf bytes.Buffer
	tw := tar.NewWriter(&buf)
	files := map[string]string{
		"greeting.txt": "hello from inside a tar",
		"nested/x.txt": "another entry",
	}
	for name, body := range files {
		hdr := &tar.Header{
			Name: name,
			Mode: 0644,
			Size: int64(len(body)),
		}
		if err := tw.WriteHeader(hdr); err != nil {
			log.Fatal(err)
		}
		if _, err := tw.Write([]byte(body)); err != nil {
			log.Fatal(err)
		}
	}
	tw.Close()

	// Read it back by walking headers until io.EOF.
	tr := tar.NewReader(&buf)
	fmt.Println("--- tar ---")
	for {
		hdr, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}
		body, _ := io.ReadAll(tr)
		fmt.Printf("%s (%d bytes): %s\n", hdr.Name, hdr.Size, body)
	}
}
