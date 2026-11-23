# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
require "net/http"
# https://pkg.go.dev/net/http/cookiejar — Package cookiejar implements an in-memory RFC 6265-compliant http.CookieJar.
require "net/http/cookiejar"
# https://pkg.go.dev/net/url — Package url parses URLs and implements query escaping.
require "net/url"
module Main
  private

    # cookiejar is the Set-Cookie/Cookie plumbing behind http.Client: give
    # the client a jar and it will remember cookies across requests.
    def self.runCookieJar
      jar, _ = cookiejar.New(nil)
      u, _ = url.Parse("https://example.com/")

      jar.SetCookies(
        u,
        [
          { Name => "session", Value => "abc123" },
          { Name => "theme", Value => "dark" }
        ]
      )

      jar.Cookies(u).each { |_, c| fmt.Printf("  %s=%s\n", c.Name, c.Value) }
      fmt.Println("cookies for sibling site:", jar.Cookies(mustURL("https://other.example.org/")))
    end

    def self.mustURL(s)
      u, err = url.Parse(s)

      if err != nil
        panic(err)
      end

      return u
    end
end
