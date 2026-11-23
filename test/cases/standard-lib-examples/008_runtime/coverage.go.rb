# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/runtime/coverage — Package coverage contains APIs for writing coverage profile data at runtime from long-running programs.
require "runtime/coverage"
module Main
  private

    # coverage lets a long-running server dump coverage snapshots without
    # having to shut down. Only useful when the program was built with
    # `go build -cover`; otherwise every write returns an error saying so.
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
