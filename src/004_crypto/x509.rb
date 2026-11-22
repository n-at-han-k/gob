# https://pkg.go.dev/crypto/ecdsa — Package ecdsa implements the Elliptic Curve Digital Signature Algorithm.
require "crypto/ecdsa"
# https://pkg.go.dev/crypto/elliptic — Package elliptic implements the standard NIST P-224, P-256, P-384, and P-521 elliptic curves.
require "crypto/elliptic"
# https://pkg.go.dev/crypto/rand — Package rand implements a cryptographically secure random number generator.
require "crypto/rand"
# https://pkg.go.dev/crypto/x509 — Package x509 implements a subset of the X.509 standard.
require "crypto/x509"
# https://pkg.go.dev/crypto/x509/pkix — Package pkix contains shared, low-level structures used for ASN.1 parsing/serialization of X.509 certificates, CRL and OCSP.
require "crypto/x509/pkix"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/math/big — Package big implements arbitrary-precision arithmetic.
require "math/big"
# https://pkg.go.dev/time — Package time provides functionality for measuring and displaying time.
require "time"
module Main
  private

    # Create a self-signed X.509 certificate, then parse it back.
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
