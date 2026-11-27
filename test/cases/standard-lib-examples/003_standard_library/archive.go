package main

import (
	"archive/tar"
	"archive/zip"
	"bytes"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

func runArchive() {
	zipDemo()
	tarDemo()
}

func zipDemo() {
	f, err := os.Create("example.zip")
	if err != nil {
		log.Fatal(err)
	}
	zw := zip.NewWriter(f)
	w, _ := zw.Create("hello.txt")
	io.Copy(w, strings.NewReader("hello from inside a zip"))
	zw.Close()
	f.Close()
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
	var buf bytes.Buffer
	tw := tar.NewWriter(&buf)
	files := map[string][]byte{
		"greeting.txt": ([]byte)("hello from inside a tar"),
		"nested/x.txt": ([]byte)("another entry"),
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
		if _, err := tw.Write(body); err != nil {
			log.Fatal(err)
		}
	}
	tw.Close()
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
