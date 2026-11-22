# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
module Main
  private

    def self.runOS
      # Environment and process info.
      fmt.Println("pid:", os.Getpid())
      fmt.Println("HOME:", os.Getenv("HOME"))
      os.Setenv("MY_VAR", "hello")
      fmt.Println("MY_VAR:", os.Getenv("MY_VAR"))
      # Working directory.
      wd, _ = os.Getwd()
      fmt.Println("cwd:", wd)
      # Write and read a temp file.
      f, err = os.CreateTemp("", "example-*.txt")

      if err != nil
        log.Fatal(err)
      end

      defer { os.Remove(f.Name()) }
      f.WriteString("hello from os\n")
      f.Close()
      data, _ = os.ReadFile(f.Name())
      fmt.Printf("read back %q from %s\n", data, f.Name())
      # os.Args holds the command-line arguments (arg 0 is the program).
      fmt.Println("args:", os.Args)
    end
end
