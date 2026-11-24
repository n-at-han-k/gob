require "fmt"
require "io"
require "log"
require "net/http"
require "net/http/httptest"

module Main

    # ()
    def runHTTP
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
