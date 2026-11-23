package main

import (
	"encoding" // https://pkg.go.dev/encoding — Package encoding defines interfaces shared by other packages that convert data to and from byte-level and textual representations.
	"fmt"      // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// The root encoding package only defines marker interfaces
// (TextMarshaler/Unmarshaler, BinaryMarshaler/Unmarshaler) that other
// packages — json, xml, etc. — check for when serialising values.
type colour struct{ R, G, B byte }

func (c colour) MarshalText() ([]byte, error) {
	return fmt.Appendf(nil, "#%02x%02x%02x", c.R, c.G, c.B), nil
}

func (c *colour) UnmarshalText(text []byte) error {
	_, err := fmt.Sscanf(string(text), "#%02x%02x%02x", &c.R, &c.G, &c.B)
	return err
}

func runEncoding() {
	// Type-assert to the interface to prove the methods are wired up.
	var m encoding.TextMarshaler = colour{255, 128, 0}
	txt, _ := m.MarshalText()
	fmt.Printf("marshalled: %s\n", txt)

	var back colour
	var u encoding.TextUnmarshaler = &back
	_ = u.UnmarshalText([]byte("#0080ff"))
	fmt.Printf("parsed:     %+v\n", back)
}
