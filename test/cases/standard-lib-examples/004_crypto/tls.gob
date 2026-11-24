require "crypto/tls"
require "fmt"

module Main

    # ()
    def runTLS
      cfg = Config.new(MinVersion: tls.VersionTLS12, NextProtos: %w[h2 http/1.1])
      fmt.Printf("min version: 0x%04x (TLS 1.2)\n", cfg.MinVersion)
      fmt.Println("ALPN offers:", cfg.NextProtos)
    end
end
