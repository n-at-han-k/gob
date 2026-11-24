package main

import (
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"

	_ "net/http/pprof"
)

func runPProf() {
	srv := httptest.NewServer(http.DefaultServeMux)
	defer srv.Close()

	resp, _ := http.Get(srv.URL + "/debug/pprof/")
	body, _ := io.ReadAll(resp.Body)
	resp.Body.Close()

	fmt.Println("status:", resp.Status)

	snippet := string(body)
	if len(snippet) > 400 {
		snippet = snippet[:400]
	}
	fmt.Println(snippet)
}
