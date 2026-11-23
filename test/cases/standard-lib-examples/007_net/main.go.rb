# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/sort — Package sort provides primitives for sorting slices and user-defined collections.
require "sort"
module Main
  # Each *.go file in this directory demonstrates one net/* subpackage.
  # Run one demo at a time, e.g.:
  #
  # go run . http
  #
  # or list what's available with `go run .`.
  demos = {
    "net" => runNet,
    "http" => runHTTP,
    "cgi" => runCGI,
    "cookiejar" => runCookieJar,
    "fcgi" => runFCGI,
    "httptest" => runHTTPTest,
    "httptrace" => runHTTPTrace,
    "httputil" => runHTTPUtil,
    "pprof" => runPProf,
    "mail" => runMail,
    "netip" => runNetip,
    "rpc" => runRPC,
    "jsonrpc" => runJSONRPC,
    "smtp" => runSMTP,
    "textproto" => runTextproto,
    "url" => runURL
  }
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
