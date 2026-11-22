# https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
require "bytes"
# https://pkg.go.dev/compress/bzip2 — Package bzip2 implements bzip2 decompression.
require "compress/bzip2"
# https://pkg.go.dev/compress/flate — Package flate implements the DEFLATE compressed data format (RFC 1951).
require "compress/flate"
# https://pkg.go.dev/compress/gzip — Package gzip implements reading and writing of gzip format compressed files (RFC 1952).
require "compress/gzip"
# https://pkg.go.dev/compress/lzw — Package lzw implements the Lempel-Ziv-Welch compressed data format.
require "compress/lzw"
# https://pkg.go.dev/compress/zlib — Package zlib implements reading and writing of zlib format compressed data (RFC 1950).
require "compress/zlib"
# https://pkg.go.dev/encoding/base64 — Package base64 implements base64 encoding as specified by RFC 4648.
require "encoding/base64"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
require "io"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    def self.runCompress
      sample = "compress me compress me compress me compress me".bytes
      gzipDemo(sample)
      flateDemo(sample)
      zlibDemo(sample)
      lzwDemo(sample)
      bzip2Demo()
      # decompression-only, so uses a pre-made payload
    end

    def self.gzipDemo(in_)
      buf = nil
      gw = gzip.NewWriter(buf)
      _, err = gw.Write(in_)

      if err != nil
        log.Fatal(err)
      end

      gw.Close()
      compressedLen = buf.Len()
      gr, err = gzip.NewReader(buf)

      if err != nil
        log.Fatal(err)
      end

      out, _ = io.ReadAll(gr)
      gr.Close()
      fmt.Printf("gzip:  %d -> %d bytes, roundtrip=%q\n", len(in_), compressedLen, out)
    end

    def self.flateDemo(in_)
      buf = nil
      fw, _ = flate.NewWriter(buf, flate.DefaultCompression)
      fw.Write(in_)
      fw.Close()
      fr = flate.NewReader(buf)
      out, _ = io.ReadAll(fr)
      fr.Close()
      fmt.Printf("flate: roundtrip=%q\n", out)
    end

    def self.zlibDemo(in_)
      buf = nil
      zw = zlib.NewWriter(buf)
      zw.Write(in_)
      zw.Close()
      zr, err = zlib.NewReader(buf)

      if err != nil
        log.Fatal(err)
      end

      out, _ = io.ReadAll(zr)
      zr.Close()
      fmt.Printf("zlib:  roundtrip=%q\n", out)
    end

    def self.lzwDemo(in_)
      buf = nil
      lw = lzw.NewWriter(buf, lzw.LSB, 8)
      lw.Write(in_)
      lw.Close()
      lr = lzw.NewReader(buf, lzw.LSB, 8)
      out, _ = io.ReadAll(lr)
      lr.Close()
      fmt.Printf("lzw:   roundtrip=%q\n", out)
    end

    def self.bzip2Demo
      # The stdlib only decompresses bzip2, so we ship a pre-compressed
      # payload (base64-encoded bzip2 of "hello bzip2\n") to decode.
      b64 =
        "QlpoOTFBWSZTWatrofEAAALZgAAQQAAQABJkwBAgADEA000EAB6j705RogeLuSKcKEhVtdD4gA=="

      compressed, err = base64.StdEncoding.DecodeString(b64)

      if err != nil
        log.Fatal(err)
      end

      r = bzip2.NewReader(bytes.NewReader(compressed))
      out, err = io.ReadAll(r)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("bzip2: decoded=%q\n", out)
    end
end
