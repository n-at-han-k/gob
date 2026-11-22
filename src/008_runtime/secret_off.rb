# go:build !goexperiment.runtimesecret
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # runtime/secret is gated behind the runtimesecret GOEXPERIMENT.
    # Without it, the package can't be imported at all — so this stub
    # stands in and tells you how to switch it on.
    def self.runSecret
      fmt.Println("runtime/secret is not available in this build.")
      fmt.Println("Rebuild with:")
      fmt.Println("  GOEXPERIMENT=runtimesecret go run . secret")
      fmt.Println("(Currently only linux/amd64 and linux/arm64 actually zero memory;")
      fmt.Println(" on other platforms secret.Do just invokes the closure directly.)")
    end
end
