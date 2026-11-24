require "fmt"
require "log"
require "os"

module Main

    # ()
    def runOS
      fmt.Println("pid:", os.Getpid())
      fmt.Println("HOME:", os.Getenv("HOME"))
      os.Setenv("MY_VAR", "hello")
      fmt.Println("MY_VAR:", os.Getenv("MY_VAR"))
      wd, _ = os.Getwd()
      fmt.Println("cwd:", wd)
      f, err = os.CreateTemp("", "example-*.txt")

      if err != nil
        log.Fatal(err)
      end

      defer { os.Remove(f.Name()) }
      f.WriteString("hello from os\n")
      f.Close()
      data, _ = os.ReadFile(f.Name())
      fmt.Printf("read back %q from %s\n", data, f.Name())
      fmt.Println("args:", os.Args)
    end
end
