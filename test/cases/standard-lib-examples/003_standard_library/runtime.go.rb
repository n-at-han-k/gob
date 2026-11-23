# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/runtime — Package runtime contains operations that interact with Go's runtime system.
require "runtime"
module Main
  private

    def self.runRuntime
      fmt.Println("go version:", runtime.Version())
      fmt.Println("GOOS/GOARCH:", runtime.GOOS, runtime.GOARCH)
      fmt.Println("NumCPU:    ", runtime.NumCPU())
      fmt.Println("NumGoroutine:", runtime.NumGoroutine())
      # Caller info: file + line of the current call site.
      pc, file, line, _ = runtime.Caller(0)
      fmt.Printf("this line: %s:%d (%s)\n", file, line, runtime.FuncForPC(pc).Name())
      # Memory stats snapshot.
      m = nil
      runtime.ReadMemStats(m)
      fmt.Printf("heap alloc: %d KiB, sys: %d KiB\n", m.HeapAlloc / 1024, m.Sys / 1024)
    end
end
