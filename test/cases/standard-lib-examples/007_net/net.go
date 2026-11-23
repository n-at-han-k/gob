package main

import (
	"fmt" // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"net" // https://pkg.go.dev/net — Package net provides a portable interface for network I/O, including TCP/IP, UDP, DNS, and Unix domain sockets.
)

// Read-only helpers only — no sockets — so this runs offline.
// See http.go for a real client/server round-trip.
func runNet() {
	ip := net.ParseIP("192.168.1.42")
	fmt.Println("ip:", ip, "loopback:", ip.IsLoopback(), "private:", ip.IsPrivate())

	addr, network, _ := net.ParseCIDR("10.0.0.5/24")
	fmt.Println("addr:", addr, "network:", network)

	host, port, _ := net.SplitHostPort("example.com:8080")
	fmt.Println("host:", host, "port:", port)

	ifs, _ := net.Interfaces()
	for _, i := range ifs {
		fmt.Printf("  %s mtu=%d flags=%s\n", i.Name, i.MTU, i.Flags)
	}
}
