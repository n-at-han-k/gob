# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/net — Package net provides a portable interface for network I/O, including TCP/IP, UDP, DNS, and Unix domain sockets.
require "net"
module Main
  private

    # This example only calls read-only helpers so it works offline.
    # See net/http for actual client/server code.
    def self.runNet
      # ParseIP recognises IPv4 and IPv6 literals.
      ip = net.ParseIP("192.168.1.42")
      fmt.Println("ip:", ip, "is loopback:", ip.IsLoopback())
      # ParseCIDR splits an address and its network.
      addr, network, _ = net.ParseCIDR("10.0.0.5/24")
      fmt.Println("addr:", addr, "network:", network)
      # SplitHostPort separates "host:port" strings safely.
      host, port, _ = net.SplitHostPort("example.com:8080")
      fmt.Println("host:", host, "port:", port)
      # Interfaces enumerates local network interfaces.
      ifs, _ = net.Interfaces()

      ifs.each do |_, i|
        fmt.Printf("  %s mtu=%d flags=%s\n", i.Name, i.MTU, i.Flags)
      end
    end
end
