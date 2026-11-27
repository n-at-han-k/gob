package main

import "fmt"

const createTable = "CREATE TABLE t(id INTEGER PRIMARY KEY);"

type Kind uint8

func (self Kind) String() string {
	switch self {
	case KindFile:
		return "file"
	case KindDirectory:
		return "directory"
	}
	return "unknown"
}

const (
	KindFile      = 0
	KindDirectory = 1
)

var tableName = "t"

type Store struct {
	name string
}

var storeCount = 0

func main() {
	fmt.Println(createTable, KindFile.String(), tableName, storeCount)
}
