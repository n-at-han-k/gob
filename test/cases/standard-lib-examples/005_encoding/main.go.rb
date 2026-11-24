require "fmt"
require "os"
require "sort"

module Main
  demos = {
    "encoding" => runEncoding,
    "ascii85" => runAscii85,
    "asn1" => runASN1,
    "base32" => runBase32,
    "base64" => runBase64,
    "binary" => runBinary,
    "csv" => runCSV,
    "gob" => runGob,
    "hex" => runHex,
    "json" => runJSON,
    "jsontext" => runJSONText,
    "jsonv2" => runJSONv2,
    "pem" => runPEM,
    "xml" => runXML
  }

  # ()
  def main
    if len(os.Args) < 2
      fmt.Println("usage: go run . <package>")
      fmt.Println("available demos:")
      names = make([], 0, len(demos))
      demos.each { |k| names = append(names, k) }
      sort.Strings(names)
      names.each { |_, n| fmt.Println("  ", n) }

      return
    end

    demo, ok = demos[os.Args[1]]

    unless ok
      fmt.Println("unknown demo:", os.Args[1])
      os.Exit(1)
    end

    demo()
  end
end
