# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/net — Package net provides a portable interface for network I/O.
require "net"
# https://pkg.go.dev/net/rpc — Package rpc provides access to the exported methods of an object across a network or other I/O connection.
require "net/rpc"
module Main
  # net/rpc exports methods on a Go value over a socket using gob
  # encoding. It's a curio nowadays — reach for gRPC in new code — but
  # the API is a nice tiny example of code generation-free RPC.
  class Arith
    def Multiply(args, reply)
      reply = args.A * args.B

      return nil
    end
  end

  class Args
    attr_accessor :A
    attr_accessor :B
  end

  private

    def self.runRPC
      srv = rpc.NewServer()
      srv.Register(Arith.new())
      l, err = net.Listen("tcp", "127.0.0.1:0")

      if err != nil
        log.Fatal(err)
      end

      defer { l.Close() }
      go { srv.Accept(l) }
      client, err = rpc.Dial("tcp", l.Addr().String())

      if err != nil
        log.Fatal(err)
      end

      defer { client.Close() }
      result = 0
      err = client.Call("Arith.Multiply", Args.new(6, 7), result)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("6 * 7 =", result)
    end
end
