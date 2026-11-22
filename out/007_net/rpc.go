package main

import (
	"fmt"
	"log"
	"net"
	"net/rpc"
)

type Arith struct {
}

func (this Arith) Multiply(args any, reply any) {
	reply = args.A * args.B
	return nil
}

type Args struct {
	A any
	B any
}

func runRPC() {
	srv := rpc.NewServer()
	srv.Register(Arith.new())
	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		l.Close()
	}()
	go func() {
		srv.Accept(l)
	}()
	client, err := rpc.Dial("tcp", l.Addr().String())
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		client.Close()
	}()
	result := 0
	err = client.Call("Arith.Multiply", Args.new(6, 7), result)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("6 * 7 =", result)
}
