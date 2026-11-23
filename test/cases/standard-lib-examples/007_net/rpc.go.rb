require "fmt"
require "log"
require "net"
require "net/rpc"
module Main
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
