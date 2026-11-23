require "fmt"
require "os"
require "runtime"
require "runtime/pprof"
module Main
  private

    def self.runPProf
      junk = make([], 0, 100)
      100.times { junk = append(junk, make([], 1024)) }
      runtime.GC()
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
      _ = junk
    end
end
