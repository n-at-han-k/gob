# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/io — Package io provides basic interfaces to I/O primitives.
require "io"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
require "net/http"
# https://pkg.go.dev/net/http/httptest — Package httptest provides utilities for HTTP testing.
require "net/http/httptest"
module Main
  private

    # Spin up a real server on a random localhost port and hit it with the
    # default client. No network access to the outside world required.
    def self.runHTTP
      srv =
        httptest.NewServer(
          http.HandlerFunc(
            lambda do |w, r|
              fmt.Fprintf(w, "hello %s, you asked for %s\n", r.RemoteAddr, r.URL.Path)
            end
          )
        )

      defer { srv.Close() }
      resp, err = http.Get(srv.URL + "/greet")

      if err != nil
        log.Fatal(err)
      end

      defer { resp.Body.Close() }
      body, _ = io.ReadAll(resp.Body)
      fmt.Println("status:", resp.Status)
      fmt.Print("body:  ", string(body))
    end
end
