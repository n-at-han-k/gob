# https://pkg.go.dev/archive/tar — Package tar implements access to tar archives.
require "archive/tar"
# https://pkg.go.dev/archive/zip — Package zip provides support for reading and writing ZIP archives.
require "archive/zip"
# https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
require "bytes"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
require "io"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
require "strings"
module Main
  private

    def self.runArchive
      zipDemo()
      tarDemo()
    end

    def self.zipDemo
      # Create a zip archive on disk.
      f, err = os.Create("example.zip")

      if err != nil
        log.Fatal(err)
      end

      zw = zip.NewWriter(f)
      w, _ = zw.Create("hello.txt")
      io.Copy(w, strings.NewReader("hello from inside a zip"))
      zw.Close()
      f.Close()
      # Read it back and print each file's contents.
      zr, err = zip.OpenReader("example.zip")

      if err != nil
        log.Fatal(err)
      end

      defer { zr.Close() }
      fmt.Println("--- zip ---")

      zr.File.each do |_, entry|
        rc, _ = entry.Open()
        body, _ = io.ReadAll(rc)
        rc.Close()
        fmt.Printf("%s: %s\n", entry.Name, body)
      end
    end

    def self.tarDemo
      # Build a tar archive in memory (writers accept any io.Writer).
      buf = nil
      tw = tar.NewWriter(buf)

      files = {
        "greeting.txt" => "hello from inside a tar",
        "nested/x.txt" => "another entry"
      }

      files.each do |name, body|
        hdr = Header.new(Name: name, Mode: 0644, Size: int64(len(body)))
        err = tw.WriteHeader(hdr)

        if err != nil
          log.Fatal(err)
        end

        _, err = tw.Write(body.bytes)

        if err != nil
          log.Fatal(err)
        end
      end

      tw.Close()
      # Read it back by walking headers until io.EOF.
      tr = tar.NewReader(buf)
      fmt.Println("--- tar ---")

      loop do
        hdr, err = tr.Next()

        if err == io.EOF
          break
        end

        if err != nil
          log.Fatal(err)
        end

        body, _ = io.ReadAll(tr)
        fmt.Printf("%s (%d bytes): %s\n", hdr.Name, hdr.Size, body)
      end
    end
end
