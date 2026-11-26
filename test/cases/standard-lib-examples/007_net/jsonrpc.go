package main

import (
	"fmt"
	"log"
	"net"
	"net/rpc"
	"net/rpc/jsonrpc"
)

func runJSONRPC() {
	srv := rpc.NewServer()
	srv.Register(Arith{})

	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		log.Fatal(err)
	}
	defer l.Close()

	go func() {
		conn, err := l.Accept()
		if err != nil {
			return
		}
		srv.ServeCodec(jsonrpc.NewServerCodec(conn))
	}()

	conn, err := net.Dial("tcp", l.Addr().String())
	if err != nil {
		log.Fatal(err)
	}
	client := rpc.NewClientWithCodec(jsonrpc.NewClientCodec(conn))
	defer client.Close()

	var result int
	if err = client.Call("Arith.Multiply", Args{9, 9}, &result); err != nil {
		log.Fatal(err)
	}
	fmt.Println("9 * 9 =", result)
}
