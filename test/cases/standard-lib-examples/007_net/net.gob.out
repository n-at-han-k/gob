package main

import (
	"fmt"
	"net"
)

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
