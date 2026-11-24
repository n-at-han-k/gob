require "fmt"
require "log"
require "net"
require "net/rpc"
require "net/rpc/jsonrpc"

module Main

    # ()
    def runJSONRPC
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
