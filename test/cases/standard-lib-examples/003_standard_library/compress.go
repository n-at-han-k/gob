package main

import (
	"bytes"
	"compress/bzip2"
	"compress/flate"
	"compress/gzip"
	"compress/lzw"
	"compress/zlib"
	"encoding/base64"
	"fmt"
	"io"
	"log"
)

func runCompress() {
	sample := ([]byte)("compress me compress me compress me compress me")
	gzipDemo(sample)
	flateDemo(sample)
	zlibDemo(sample)
	lzwDemo(sample)
	bzip2Demo()
}

func gzipDemo(input []byte) {
	var buf bytes.Buffer
	gw := gzip.NewWriter(&buf)
	if _, err := gw.Write(input); err != nil {
		log.Fatal(err)
	}
	gw.Close()
	compressedLen := buf.Len()
	gr, err := gzip.NewReader(&buf)
	if err != nil {
		log.Fatal(err)
	}
	out, _ := io.ReadAll(gr)
	gr.Close()
	fmt.Printf("gzip:  %d -> %d bytes, roundtrip=%q\n", len(input), compressedLen, out)
}

func flateDemo(input []byte) {
	var buf bytes.Buffer
	fw, _ := flate.NewWriter(&buf, flate.DefaultCompression)
	fw.Write(input)
	fw.Close()
	fr := flate.NewReader(&buf)
	out, _ := io.ReadAll(fr)
	fr.Close()
	fmt.Printf("flate: roundtrip=%q\n", out)
}

func zlibDemo(input []byte) {
	var buf bytes.Buffer
	zw := zlib.NewWriter(&buf)
	zw.Write(input)
	zw.Close()
	zr, err := zlib.NewReader(&buf)
	if err != nil {
		log.Fatal(err)
	}
	out, _ := io.ReadAll(zr)
	zr.Close()
	fmt.Printf("zlib:  roundtrip=%q\n", out)
}

func lzwDemo(input []byte) {
	var buf bytes.Buffer
	lw := lzw.NewWriter(&buf, lzw.LSB, 8)
	lw.Write(input)
	lw.Close()
	lr := lzw.NewReader(&buf, lzw.LSB, 8)
	out, _ := io.ReadAll(lr)
	lr.Close()
	fmt.Printf("lzw:   roundtrip=%q\n", out)
}

func bzip2Demo() {
	const b64 = "QlpoOTFBWSZTWatrofEAAALZgAAQQAAQABJkwBAgADEA000EAB6j705RogeLuSKcKEhVtdD4gA=="
	compressed, err := base64.StdEncoding.DecodeString(b64)
	if err != nil {
		log.Fatal(err)
	}
	r := bzip2.NewReader(bytes.NewReader(compressed))
	out, err := io.ReadAll(r)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("bzip2: decoded=%q\n", out)
}
