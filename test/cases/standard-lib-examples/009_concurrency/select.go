package main

import (
	"fmt"
	"time"
)

func runSelect() {
	fast := make(chan string)
	slow := make(chan string)

	go func() {
		time.Sleep(10 * time.Millisecond)
		fast <- "fast"
	}()

	go func() {
		time.Sleep(200 * time.Millisecond)
		slow <- "slow"
	}()

	for range 2 {
		select {
		case msg := <-fast:
			fmt.Println("got:", msg)
		case msg := <-slow:
			fmt.Println("got:", msg)
		case <-time.After(50 * time.Millisecond):
			fmt.Println("timed out waiting")
		}
	}

	idle := make(chan int, 1)

	select {
	case n := <-idle:
		fmt.Println("drained:", n)
	default:
		fmt.Println("nothing ready")
	}
}
