package main

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"log"
)

func runBinary() {
	buf := nil
	binary.Write(buf, binary.BigEndian, uint32(3735928559))
	binary.Write(buf, binary.LittleEndian, uint16(4660))
	fmt.Printf("bytes: %x\n", buf.Bytes())
	a := 0
	b := 0
	err := binary.Read(buf, binary.BigEndian, a)
	if err != nil {
		log.Fatal(err)
	}
	binary.Read(buf, binary.LittleEndian, b)
	fmt.Printf("a=%#x b=%#x\n", a, b)
	vbuf := nil
	n := binary.PutVarint(vbuf, -12345)
	fmt.Printf("varint(-12345) = %x (%d bytes)\n", vbuf[nil:n], n)
	v, _ := binary.Varint(vbuf[nil:n])
	fmt.Println("decoded:", v)
}
