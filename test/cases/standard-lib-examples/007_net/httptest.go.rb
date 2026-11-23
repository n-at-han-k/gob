# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
require "net/http"
# https://pkg.go.dev/net/http/httptest — Package httptest provides utilities for HTTP testing.
require "net/http/httptest"
module Main
  private

    # httptest gives you two things: NewServer (a real server on a random
    # port) and NewRecorder (an in-memory ResponseWriter). Use the recorder
    # when you want to unit-test a handler without opening a socket.
    def self.runHTTPTest
      handler =
        http.HandlerFunc(
          lambda do |w, r|
            w.Header().Set("X-Test", "yes")
            w.WriteHeader(http.StatusTeapot)
            fmt.Fprintln(w, "short and stout")
          end
        )

      req = httptest.NewRequest(http.MethodGet, "/kettle", nil)
      rec = httptest.NewRecorder()
      handler.ServeHTTP(rec, req)
      resp = rec.Result()
      fmt.Println("status:", resp.Status)
      fmt.Println("header:", resp.Header.Get("X-Test"))
      fmt.Print("body:  ", rec.Body.String())
    end
end
