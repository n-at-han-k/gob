package main

import (
	"encoding"
	"fmt"
)

type Colour struct {
	R any
	G any
	B any
}

func (this Colour) MarshalText() {
	return fmt.Appendf(nil, "#%02x%02x%02x", this.R, this.G, this.B), nil
}
func (this Colour) UnmarshalText(text any) {
	_, err := fmt.Sscanf(string(text), "#%02x%02x%02x", this.R, this.G, this.B)
	return err
}

func runEncoding() {
	m := Colour.new(255, 128, 0)
	txt, _ := m.MarshalText()
	fmt.Printf("marshalled: %s\n", txt)
	back := nil
	u := back
	_ = u.UnmarshalText("#0080ff".bytes)
	fmt.Printf("parsed:     %+v\n", back)
}
