require "context"
require "fmt"
require "os"
require "runtime/trace"
require "sync"
require "time"

module Main

    # ()
    def runTrace
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
