package main

import (
	"fmt"
	"time"
)

func runTime() {
	now := time.Now()
	fmt.Println("iso:  ", now.Format(time.RFC3339))
	fmt.Println("ymd:  ", now.Format("2006-01-02"))
	t, _ := time.Parse("2006-01-02", "2026-07-15")
	fmt.Println("parsed:", t)
	tomorrow := now.Add(24 * time.Hour)
	fmt.Println("delta:", tomorrow.Sub(now))
	fmt.Println("after:", tomorrow.After(now))
	start := time.Now()
	time.Sleep(50 * time.Millisecond)
	fmt.Println("slept:", time.Since(start))
}
