# https://pkg.go.dev/encoding/asn1 — Package asn1 implements parsing of DER-encoded ASN.1 data structures (ITU-T Rec X.690).
require "encoding/asn1"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  # ASN.1 encodes structured data as a compact binary format used by
  # X.509 certificates, LDAP, SNMP, and other protocols.
  class Person
    attr_accessor :Name
    attr_accessor :Age
  end

  private

    def self.runASN1
      p = Person.new(Name: "Nathan", Age: 30)
      der, err = asn1.Marshal(p)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("DER (%d bytes): %x\n", len(der), der)
      back = nil
      _, err = asn1.Unmarshal(der, back)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("parsed: %+v\n", back)
    end
end
