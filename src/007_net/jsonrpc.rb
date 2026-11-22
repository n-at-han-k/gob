# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/net — Package net provides a portable interface for network I/O.
require "net"
# https://pkg.go.dev/net/rpc — Package rpc provides access to the exported methods of an object across a network.
require "net/rpc"
# https://pkg.go.dev/net/rpc/jsonrpc — Package jsonrpc implements a JSON-RPC 1.0 ClientCodec and ServerCodec for the rpc package.
require "net/rpc/jsonrpc"
module Main
  private

    # Same net/rpc plumbing as rpc.go, but with a JSON codec on the wire.
    # Any JSON-RPC 1.0 client (in any language) can now call our method.
    def self.runJSONRPC
      srv = rpc.NewServer()
      srv.Register(Arith.new())
      l, err = net.Listen("tcp", "127.0.0.1:0")

      if err != nil
        log.Fatal(err)
      end

      defer { l.Close() }

      go do
        conn, err = l.Accept()

        if err != nil
          return
        end

        srv.ServeCodec(jsonrpc.NewServerCodec(conn))
      end.()

      conn, err = net.Dial("tcp", l.Addr().String())

      if err != nil
        log.Fatal(err)
      end

      client = rpc.NewClientWithCodec(jsonrpc.NewClientCodec(conn))
      defer { client.Close() }
      result = 0
      err = client.Call("Arith.Multiply", Args.new(9, 9), result)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("9 * 9 =", result)
    end
end
