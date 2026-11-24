package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strings"
)

func runCSV() {

	w := csv.NewWriter(os.Stdout)
	w.WriteAll([][]string{
		{"name", "city", "notes"},
		{"Nathan", "Wellington", "hello, world"},
		{"Ada", "London", `she said "hi"`},
	})
	w.Flush()

	input := "id,label\n1,apple\n2,orange\n3,pear\n"
	r := csv.NewReader(strings.NewReader(input))
	records, err := r.ReadAll()
	if err != nil {
		log.Fatal(err)
	}
	for _, rec := range records {
		fmt.Println("row:", rec)
	}
}
