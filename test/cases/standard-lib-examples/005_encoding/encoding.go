package main

import (
	"encoding"
	"fmt"
)

type colour struct {
	R byte
	G byte
	B byte
}

func (self colour) MarshalText() ([]byte, error) {
	return fmt.Appendf(nil, "#%02x%02x%02x", self.R, self.G, self.B), nil
}

func (self *colour) UnmarshalText(text []byte) error {
	_, err := fmt.Sscanf(string(text), "#%02x%02x%02x", &self.R, &self.G, &self.B)
	return err
}

func runEncoding() {
	var m encoding.TextMarshaler = colour{255, 128, 0}
	txt, _ := m.MarshalText()
	fmt.Printf("marshalled: %s\n", txt)

	var back colour
	var u encoding.TextUnmarshaler
	u = &back
	_ = u.UnmarshalText([]byte("#0080ff"))
	fmt.Printf("parsed:     %+v\n", back)
}
