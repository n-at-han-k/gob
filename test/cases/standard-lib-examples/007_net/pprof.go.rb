# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
require "io"
# https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
require "net/http"
# https://pkg.go.dev/net/http/httptest — Package httptest provides utilities for HTTP testing.
require "net/http/httptest"
# Importing net/http/pprof for its side effect: it registers
# /debug/pprof/* on http.DefaultServeMux.
# https://pkg.go.dev/net/http/pprof — Package pprof serves runtime profiling data over HTTP. -- imported as _
require "net/http/pprof"
module Main
  private

    # A blank import of net/http/pprof adds /debug/pprof/* to
    # http.DefaultServeMux — hit that in production to grab profiles with
    # `go tool pprof`.
    def self.runPProf
      srv = httptest.NewServer(http.DefaultServeMux)
      defer { srv.Close() }
      resp, _ = http.Get(srv.URL + "/debug/pprof/")
      body, _ = io.ReadAll(resp.Body)
      resp.Body.Close()
      fmt.Println("status:", resp.Status)
      # The index page is HTML; show enough to prove it's the pprof one.
      snippet = string(body)

      if len(snippet) > 400
        snippet = snippet[...400]
      end

      fmt.Println(snippet)
    end
end
