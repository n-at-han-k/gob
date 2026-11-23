require "fmt"
require "os"
require "runtime/coverage"
module Main
  private

    def self.runCoverage
      dir, _ = os.MkdirTemp("", "cover-")
      defer { os.RemoveAll(dir) }
      err = coverage.WriteMetaDir(dir)

      if err != nil
        fmt.Println("WriteMetaDir:", err)
      else
        fmt.Println("wrote meta to", dir)
      end

      err = coverage.WriteCountersDir(dir)

      if err != nil
        fmt.Println("WriteCountersDir:", err)
      end

      err = coverage.ClearCounters()

      if err != nil
        fmt.Println("ClearCounters:", err)
      end

      fmt.Println("(rebuild with `go build -cover` for these to succeed)")
    end
end
