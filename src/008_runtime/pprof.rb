# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/runtime — Package runtime contains operations that interact with Go's runtime system.
require "runtime"
# https://pkg.go.dev/runtime/pprof — Package pprof writes runtime profiling data in the format expected by the pprof visualization tool.
require "runtime/pprof"
module Main
  private

    # runtime/pprof is the library equivalent of net/http/pprof: same
    # profile data (heap, goroutine, CPU, ...), but written to any writer.
    def self.runPProf
      # Force some allocations so the heap profile isn't empty.
      junk = make([], 0, 100)
      100.times { junk = append(junk, make([], 1024)) }
      runtime.GC()
      # sample the live heap.
      f, err = os.CreateTemp("", "heap-*.prof")

      if err != nil
        fmt.Println("temp:", err)

        return
      end

      defer { os.Remove(f.Name()) }
      defer { f.Close() }
      err = pprof.Lookup("heap").WriteTo(f, 0)

      if err != nil
        fmt.Println("write:", err)

        return
      end

      info, _ = f.Stat()
      fmt.Printf("wrote heap profile: %s (%d bytes)\n", f.Name(), info.Size())
      fmt.Println("view with: go tool pprof", f.Name())
      # Ensure junk stays live to the profile call.
      _ = junk
    end
end
