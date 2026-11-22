package main

import (
	"encoding/asn1"
	"fmt"
	"log"
)

type Person struct {
	Name any
	Age  any
}

func runASN1() {
	p := Person.new(map[any]any{Name: "Nathan", Age: 30})
	der, err := asn1.Marshal(p)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("DER (%d bytes): %x\n", len(der), der)
	back := nil
	_, err := asn1.Unmarshal(der, back)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("parsed: %+v\n", back)
}
