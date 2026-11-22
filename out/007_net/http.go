package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
)

func runHTTP() {
	srv := httptest.NewServer(http.HandlerFunc(func(w any, r any) {
		fmt.Fprintf(w, "hello %s, you asked for %s\n", r.RemoteAddr, r.URL.Path)
	}))
	defer func() {
		srv.Close()
	}()
	resp, err := http.Get(srv.URL + "/greet")
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		resp.Body.Close()
	}()
	body, _ := io.ReadAll(resp.Body)
	fmt.Println("status:", resp.Status)
	fmt.Print("body:  ", string(body))
}
