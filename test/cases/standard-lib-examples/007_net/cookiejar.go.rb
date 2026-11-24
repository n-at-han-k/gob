require "fmt"
require "net/http"
require "net/http/cookiejar"
require "net/url"

module Main

    # ()
    def runCookieJar
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

    # (string) -> *url.URL
    def mustURL(s)
      u, err = url.Parse(s)

      if err != nil
        panic(err)
      end

      return u
    end
end
