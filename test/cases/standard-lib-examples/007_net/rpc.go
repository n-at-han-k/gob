package main

import (
	"fmt"     
	"log"     
	"net"     
	"net/rpc" 
)

type Arith struct{}

type Args struct{ A, B int }

func (Arith) Multiply(args Args, reply *int) error {
	*reply = args.A * args.B
	return nil
}

func runRPC() {
	srv := rpc.NewServer()
	srv.Register(Arith{})

	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		log.Fatal(err)
	}
	defer l.Close()
	go srv.Accept(l)

	client, err := rpc.Dial("tcp", l.Addr().String())
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()

	var result int
	if err := client.Call("Arith.Multiply", Args{6, 7}, &result); err != nil {
		log.Fatal(err)
	}
	fmt.Println("6 * 7 =", result)
}
