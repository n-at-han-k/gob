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
	srv.Register(Arith.new())
	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		l.Close()
	}()
	go func() {
		conn, err := l.Accept()
		if err != nil {
			return
		}
		srv.ServeCodec(jsonrpc.NewServerCodec(conn))
	}().call()
	conn, err := net.Dial("tcp", l.Addr().String())
	if err != nil {
		log.Fatal(err)
	}
	client := rpc.NewClientWithCodec(jsonrpc.NewClientCodec(conn))
	defer func() {
		client.Close()
	}()
	result := 0
	err = client.Call("Arith.Multiply", Args.new(9, 9), result)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("9 * 9 =", result)
}
