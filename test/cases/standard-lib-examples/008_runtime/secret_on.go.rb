require "fmt"
require "runtime/secret"

module Main

    # ()
    def runSecret
      key = "hunter2-shhhh".bytes

      secret.Do(
        lambda do
          mixed = nil
          mixed.each { |i| mixed[i] = key[i % len(key)] ^ byte(i) }
          fmt.Printf("inside Do: mixed=%x, Enabled=%v\n", mixed, secret.Enabled())
        end
      )

      fmt.Println("outside Do: registers and stack that Do touched are now zeroed.")
    end
end
