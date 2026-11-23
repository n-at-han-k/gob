# go:build goexperiment.runtimesecret
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/runtime/secret — Package secret contains helper functions for zeroing out memory that is otherwise invisible to a user program in the service of forward secrecy.
require "runtime/secret"
module Main
  private

    # secret.Do runs a closure and then zeroes any stack and registers it
    # touched. Intended for constant-time cryptographic code where you
    # don't want a key sitting in memory after use.
    def self.runSecret
      key = "hunter2-shhhh".bytes

      secret.Do(
        lambda do
          # Pretend to do something with the key: XOR-mask a nonce, say.
          mixed = nil
          mixed.each { |i| mixed[i] = key[i % len(key)] ^ byte(i) }
          fmt.Printf("inside Do: mixed=%x, Enabled=%v\n", mixed, secret.Enabled())
        end
      )

      fmt.Println("outside Do: registers and stack that Do touched are now zeroed.")
    end
end
