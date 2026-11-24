require "archive/tar"
require "archive/zip"
require "bytes"
require "fmt"
require "io"
require "log"
require "os"
require "strings"

module Main

    # ()
    def runArchive
      zipDemo()
      tarDemo()
    end

    # ()
    def zipDemo
      f, err = os.Create("example.zip")

      if err != nil
        log.Fatal(err)
      end

      zw = zip.NewWriter(f)
      w, _ = zw.Create("hello.txt")
      io.Copy(w, strings.NewReader("hello from inside a zip"))
      zw.Close()
      f.Close()
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

    # ()
    def tarDemo
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
