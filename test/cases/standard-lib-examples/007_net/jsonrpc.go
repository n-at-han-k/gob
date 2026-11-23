package main

import (
	"fmt"             // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"log"             // https://pkg.go.dev/log — Package log implements a simple logging package.
	"net"             // https://pkg.go.dev/net — Package net provides a portable interface for network I/O.
	"net/rpc"         // https://pkg.go.dev/net/rpc — Package rpc provides access to the exported methods of an object across a network.
	"net/rpc/jsonrpc" // https://pkg.go.dev/net/rpc/jsonrpc — Package jsonrpc implements a JSON-RPC 1.0 ClientCodec and ServerCodec for the rpc package.
)

// Same net/rpc plumbing as rpc.go, but with a JSON codec on the wire.
// Any JSON-RPC 1.0 client (in any language) can now call our method.
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
	if err := client.Call("Arith.Multiply", Args{9, 9}, &result); err != nil {
		log.Fatal(err)
	}
	fmt.Println("9 * 9 =", result)
}
