require "fmt"
require "net/http"
require "net/http/httptest"
require "net/http/httptrace"
module Main
  private

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
