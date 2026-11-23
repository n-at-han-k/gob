package main

import (
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"     // https://pkg.go.dev/log — Package log implements a simple logging package.
	"net"     // https://pkg.go.dev/net — Package net provides a portable interface for network I/O.
	"net/rpc" // https://pkg.go.dev/net/rpc — Package rpc provides access to the exported methods of an object across a network or other I/O connection.
)

// net/rpc exports methods on a Go value over a socket using gob
// encoding. It's a curio nowadays — reach for gRPC in new code — but
// the API is a nice tiny example of code generation-free RPC.
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
