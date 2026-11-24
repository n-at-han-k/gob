package main

import (
	"fmt"                
	"net/http"           
	"net/http/httptest"  
	"net/http/httptrace" 
)

func runHTTPTrace() {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "hello")
	}))
	defer srv.Close()

	trace := &httptrace.ClientTrace{
		GetConn:              func(host string) { fmt.Println("GetConn:", host) },
		GotConn:              func(info httptrace.GotConnInfo) { fmt.Println("GotConn: reused=", info.Reused) },
		WroteHeaders:         func() { fmt.Println("WroteHeaders") },
		GotFirstResponseByte: func() { fmt.Println("GotFirstResponseByte") },
	}

	req, _ := http.NewRequest("GET", srv.URL, nil)
	req = req.WithContext(httptrace.WithClientTrace(req.Context(), trace))

	resp, _ := http.DefaultTransport.RoundTrip(req)
	resp.Body.Close()
	fmt.Println("status:", resp.Status)
}
