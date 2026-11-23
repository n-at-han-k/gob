require "fmt"
require "net/http"
require "net/http/httptest"
require "net/http/httputil"
require "net/url"
module Main
  private

    def self.runHTTPUtil
      upstream =
        httptest.NewServer(http.HandlerFunc(lambda { |w, r| fmt.Fprintf(w, "upstream got %s\n", r.URL.Path) }))

      defer { upstream.Close() }
      target, _ = url.Parse(upstream.URL)
      proxy = httptest.NewServer(httputil.NewSingleHostReverseProxy(target))
      defer { proxy.Close() }
      resp, _ = http.Get(proxy.URL + "/echo")
      dump, _ = httputil.DumpResponse(resp, true)
      fmt.Print(string(dump))
    end
end
