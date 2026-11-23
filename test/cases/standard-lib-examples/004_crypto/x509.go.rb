require "crypto/ecdsa"
require "crypto/elliptic"
require "crypto/rand"
require "crypto/x509"
require "crypto/x509/pkix"
require "fmt"
require "log"
require "math/big"
require "time"
module Main
  private

    def self.runX509
      priv, err = ecdsa.GenerateKey(elliptic.P256(), rand.Reader)

      if err != nil
        log.Fatal(err)
      end

      tmpl =
        Certificate.new(
          SerialNumber: big.NewInt(1),
          Subject:
            Name.new(CommonName: "example.local", Organization: ["Learning Go"]),
          NotBefore: time.Now(),
          NotAfter: time.Now().Add(24 * time.Hour),
          KeyUsage: x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
          IsCA: true
        )

      der, err =
        x509.CreateCertificate(rand.Reader, tmpl, tmpl, priv.PublicKey, priv)

      if err != nil
        log.Fatal(err)
      end

      cert, _ = x509.ParseCertificate(der)
      fmt.Println("subject:  ", cert.Subject)
      fmt.Println("issuer:   ", cert.Issuer)
      fmt.Println("not after:", cert.NotAfter.Format(time.RFC3339))
      fmt.Println("is CA:    ", cert.IsCA)
    end
end
