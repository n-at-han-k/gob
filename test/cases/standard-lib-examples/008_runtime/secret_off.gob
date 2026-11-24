require "fmt"

module Main

    # ()
    def runSecret
      fmt.Println("runtime/secret is not available in this build.")
      fmt.Println("Rebuild with:")
      fmt.Println("  GOEXPERIMENT=runtimesecret go run . secret")
      fmt.Println("(Currently only linux/amd64 and linux/arm64 actually zero memory;")
      fmt.Println(" on other platforms secret.Do just invokes the closure directly.)")
    end
end
