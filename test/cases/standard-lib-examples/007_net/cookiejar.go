package main

import (
	"fmt"                // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"net/http"           // https://pkg.go.dev/net/http — Package http provides HTTP client and server implementations.
	"net/http/cookiejar" // https://pkg.go.dev/net/http/cookiejar — Package cookiejar implements an in-memory RFC 6265-compliant http.CookieJar.
	"net/url"            // https://pkg.go.dev/net/url — Package url parses URLs and implements query escaping.
)

// cookiejar is the Set-Cookie/Cookie plumbing behind http.Client: give
// the client a jar and it will remember cookies across requests.
func runCookieJar() {
	jar, _ := cookiejar.New(nil)
	u, _ := url.Parse("https://example.com/")

	jar.SetCookies(u, []*http.Cookie{
		{Name: "session", Value: "abc123"},
		{Name: "theme", Value: "dark"},
	})

	for _, c := range jar.Cookies(u) {
		fmt.Printf("  %s=%s\n", c.Name, c.Value)
	}
	fmt.Println("cookies for sibling site:", jar.Cookies(mustURL("https://other.example.org/")))
}

func mustURL(s string) *url.URL {
	u, err := url.Parse(s)
	if err != nil {
		panic(err)
	}
	return u
}
