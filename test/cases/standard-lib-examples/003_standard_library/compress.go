package main

import (
	"bytes"           // https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
	"compress/bzip2"  // https://pkg.go.dev/compress/bzip2 — Package bzip2 implements bzip2 decompression.
	"compress/flate"  // https://pkg.go.dev/compress/flate — Package flate implements the DEFLATE compressed data format (RFC 1951).
	"compress/gzip"   // https://pkg.go.dev/compress/gzip — Package gzip implements reading and writing of gzip format compressed files (RFC 1952).
	"compress/lzw"    // https://pkg.go.dev/compress/lzw — Package lzw implements the Lempel-Ziv-Welch compressed data format.
	"compress/zlib"   // https://pkg.go.dev/compress/zlib — Package zlib implements reading and writing of zlib format compressed data (RFC 1950).
	"encoding/base64" // https://pkg.go.dev/encoding/base64 — Package base64 implements base64 encoding as specified by RFC 4648.
	"fmt"             // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"io"              // https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
	"log"             // https://pkg.go.dev/log — Package log implements a simple logging package.
)

func runCompress() {
	sample := []byte("compress me compress me compress me compress me")

	gzipDemo(sample)
	flateDemo(sample)
	zlibDemo(sample)
	lzwDemo(sample)
	bzip2Demo() // decompression-only, so uses a pre-made payload
}

func gzipDemo(in []byte) {
	var buf bytes.Buffer
	gw := gzip.NewWriter(&buf)
	if _, err := gw.Write(in); err != nil {
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
	fmt.Printf("gzip:  %d -> %d bytes, roundtrip=%q\n", len(in), compressedLen, out)
}

func flateDemo(in []byte) {
	var buf bytes.Buffer
	fw, _ := flate.NewWriter(&buf, flate.DefaultCompression)
	fw.Write(in)
	fw.Close()

	fr := flate.NewReader(&buf)
	out, _ := io.ReadAll(fr)
	fr.Close()
	fmt.Printf("flate: roundtrip=%q\n", out)
}

func zlibDemo(in []byte) {
	var buf bytes.Buffer
	zw := zlib.NewWriter(&buf)
	zw.Write(in)
	zw.Close()

	zr, err := zlib.NewReader(&buf)
	if err != nil {
		log.Fatal(err)
	}
	out, _ := io.ReadAll(zr)
	zr.Close()
	fmt.Printf("zlib:  roundtrip=%q\n", out)
}

func lzwDemo(in []byte) {
	var buf bytes.Buffer
	lw := lzw.NewWriter(&buf, lzw.LSB, 8)
	lw.Write(in)
	lw.Close()

	lr := lzw.NewReader(&buf, lzw.LSB, 8)
	out, _ := io.ReadAll(lr)
	lr.Close()
	fmt.Printf("lzw:   roundtrip=%q\n", out)
}

func bzip2Demo() {
	// The stdlib only decompresses bzip2, so we ship a pre-compressed
	// payload (base64-encoded bzip2 of "hello bzip2\n") to decode.
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
