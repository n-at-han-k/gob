require "fmt"
require "log"
require "net/netip"
module Main
  private

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

      seen = {
        netip.MustParseAddr("1.1.1.1") => 3,
        netip.MustParseAddr("8.8.8.8") => 1
      }

      fmt.Println("map:       ", seen)
    end
end
