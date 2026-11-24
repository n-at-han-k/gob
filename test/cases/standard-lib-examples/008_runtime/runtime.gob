require "fmt"
require "runtime"

module Main

    # ()
    def runRuntime
      fmt.Println("go version:  ", runtime.Version())
      fmt.Println("GOOS/GOARCH: ", runtime.GOOS, runtime.GOARCH)
      fmt.Println("NumCPU:      ", runtime.NumCPU())
      fmt.Println("NumGoroutine:", runtime.NumGoroutine())
      fmt.Println("GOMAXPROCS:  ", runtime.GOMAXPROCS(0))
      pc, file, line, _ = runtime.Caller(0)
      fmt.Printf("here: %s:%d (%s)\n", file, line, runtime.FuncForPC(pc).Name())
      m = nil
      runtime.ReadMemStats(m)
      fmt.Printf("heap alloc: %d KiB, sys: %d KiB, num GC: %d\n", m.HeapAlloc / 1024, m.Sys / 1024, m.NumGC)
    end
end
