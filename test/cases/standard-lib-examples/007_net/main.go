package main

import (
	"fmt"  
	"os"   
	"sort" 
)

var demos = map[string]func(){
	"net":        runNet,
	"http":       runHTTP,
	"cgi":        runCGI,
	"cookiejar":  runCookieJar,
	"fcgi":       runFCGI,
	"httptest":   runHTTPTest,
	"httptrace":  runHTTPTrace,
	"httputil":   runHTTPUtil,
	"pprof":      runPProf,
	"mail":       runMail,
	"netip":      runNetip,
	"rpc":        runRPC,
	"jsonrpc":    runJSONRPC,
	"smtp":       runSMTP,
	"textproto":  runTextproto,
	"url":        runURL,
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("usage: go run . <package>")
		fmt.Println("available demos:")
		names := make([]string, 0, len(demos))
		for k := range demos {
			names = append(names, k)
		}
		sort.Strings(names)
		for _, n := range names {
			fmt.Println("  ", n)
		}
		return
	}
	demo, ok := demos[os.Args[1]]
	if !ok {
		fmt.Println("unknown demo:", os.Args[1])
		os.Exit(1)
	}
	demo()
}
