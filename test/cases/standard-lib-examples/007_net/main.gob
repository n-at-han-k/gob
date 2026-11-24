require "fmt"
require "os"
require "sort"

module Main
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
