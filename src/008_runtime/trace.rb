# https://pkg.go.dev/context — Package context defines the Context type, which carries deadlines, cancellation signals, and other request-scoped values.
require "context"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/runtime/trace — Package trace contains facilities for programs to generate traces for the Go execution tracer.
require "runtime/trace"
# https://pkg.go.dev/sync — Package sync provides basic synchronization primitives.
require "sync"
# https://pkg.go.dev/time — Package time provides functionality for measuring and displaying time.
require "time"
module Main
  private

    # runtime/trace records every scheduler event — goroutine start/stop,
    # syscall, GC, network I/O — into a file you can open with
    # `go tool trace`. Add trace.WithRegion / trace.Log calls for
    # user-defined annotations that show up in the trace viewer.
    def self.runTrace
      f, _ = os.CreateTemp("", "trace-*.out")
      defer { os.Remove(f.Name()) }
      defer { f.Close() }
      err = trace.Start(f)

      if err != nil
        fmt.Println("start:", err)

        return
      end

      wg = nil

      3.times do |i|
        wg.Add(1)

        go do |id|
          defer { wg.Done() }

          trace.WithRegion(
            context.Background(),
            fmt.Sprintf("worker-%d", id),
            lambda { time.Sleep(5 * time.Millisecond) }
          )
        end.(i)
      end

      wg.Wait()
      trace.Stop()
      info, _ = f.Stat()
      fmt.Printf("wrote trace: %s (%d bytes)\n", f.Name(), info.Size())
      fmt.Println("view with: go tool trace", f.Name())
    end
end
