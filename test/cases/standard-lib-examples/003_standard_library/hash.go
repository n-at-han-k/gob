package main

import (
	"fmt"
	"hash"
	"hash/adler32"
	"hash/crc32"
	"hash/crc64"
	"hash/fnv"
	"hash/maphash"
)

type hashEntry struct {
	name string
	h    hash.Hash
}

type pair struct {
	a int
	b int
}

func runHash() {
	data := ([]byte)("hello")
	hashes := []hashEntry{
		hashEntry{"adler32", adler32.New()},
		hashEntry{"crc32", crc32.NewIEEE()},
		hashEntry{"crc64", crc64.New(crc64.MakeTable(crc64.ISO))},
		hashEntry{"fnv-64a", fnv.New64a()},
	}
	for _, entry := range hashes {
		entry.h.Write(data)
		fmt.Printf("%-8s size=%d  sum=%x\n", entry.name, entry.h.Size(), entry.h.Sum(nil))
	}
	fmt.Printf("adler32 (Checksum): %x\n", adler32.Checksum(data))
	fmt.Printf("crc32   (IEEE):     %x\n", crc32.ChecksumIEEE(data))
	seed := maphash.MakeSeed()
	fmt.Printf("maphash string(%q): %x\n", data, maphash.String(seed, string(data)))
	fmt.Printf("maphash comparable: %x\n", maphash.Comparable(seed, pair{1, 2}))
}
