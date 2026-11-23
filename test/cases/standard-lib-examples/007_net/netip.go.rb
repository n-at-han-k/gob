# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/net/netip — Package netip defines an IP address type that's a small value type.
require "net/netip"
module Main
  private

    # netip.Addr is a small, comparable, allocation-free replacement for
    # net.IP — you can use it as a map key and it lands in a register.
    def self.runNetip
      addr, err = netip.ParseAddr("2001:db8::1")

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("addr:      ", addr)
      fmt.Println("is v6?     ", addr.Is6())
      fmt.Println("is private?", addr.IsPrivate())
      prefix = netip.MustParsePrefix("10.0.0.0/8")
      fmt.Println("prefix:    ", prefix)
      fmt.Println("contains 10.1.2.3?", prefix.Contains(netip.MustParseAddr("10.1.2.3")))

      # Use as a map key — legal because Addr is comparable.
      seen = {
        netip.MustParseAddr("1.1.1.1") => 3,
        netip.MustParseAddr("8.8.8.8") => 1
      }

      fmt.Println("map:       ", seen)
    end
end
