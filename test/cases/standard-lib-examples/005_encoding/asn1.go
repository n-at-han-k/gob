package main

import (
	"encoding/asn1" // https://pkg.go.dev/encoding/asn1 — Package asn1 implements parsing of DER-encoded ASN.1 data structures (ITU-T Rec X.690).
	"fmt"           // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"           // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// ASN.1 encodes structured data as a compact binary format used by
// X.509 certificates, LDAP, SNMP, and other protocols.
type person struct {
	Name string
	Age  int
}

func runASN1() {
	p := person{Name: "Nathan", Age: 30}
	der, err := asn1.Marshal(p)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("DER (%d bytes): %x\n", len(der), der)

	var back person
	if _, err := asn1.Unmarshal(der, &back); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("parsed: %+v\n", back)
}
