# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
require "net/http"
# https://pkg.go.dev/net/http/httptest — Package httptest provides utilities for HTTP testing.
require "net/http/httptest"
# https://pkg.go.dev/net/http/httptrace — Package httptrace provides mechanisms to trace the events within HTTP client requests.
require "net/http/httptrace"
module Main
  private

    # httptrace hooks into every phase of an outgoing request — DNS,
    # connection reuse, TLS handshake, write start, first byte. Attach a
    # ClientTrace via context and the transport calls the callbacks.
    def self.runHTTPTrace
      srv =
        httptest.NewServer(http.HandlerFunc(lambda { |w, r| fmt.Fprintln(w, "hello") }))

      defer { srv.Close() }

      trace =
        ClientTrace.new(
          GetConn: lambda { |host| fmt.Println("GetConn:", host) },
          GotConn: lambda { |info| fmt.Println("GotConn: reused=", info.Reused) },
          WroteHeaders: lambda { fmt.Println("WroteHeaders") },
          GotFirstResponseByte: lambda { fmt.Println("GotFirstResponseByte") }
        )

      req, _ = http.NewRequest("GET", srv.URL, nil)
      req = req.WithContext(httptrace.WithClientTrace(req.Context(), trace))
      resp, _ = http.DefaultTransport.RoundTrip(req)
      resp.Body.Close()
      fmt.Println("status:", resp.Status)
    end
end
