# https://pkg.go.dev/flag — Package flag implements command-line flag parsing.
require "flag"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
module Main
  private

    def self.runFlag
      # A local FlagSet lets us skip os.Args[0..1] (program + subcommand)
      # without disturbing the process-global flag package.
      fs = flag.NewFlagSet("demo", flag.ExitOnError)
      name = fs.String("name", "world", "who to greet")
      loud = fs.Bool("loud", false, "shout the greeting")
      count = fs.Int("count", 1, "how many times")
      fs.Parse(os.Args[2...])
      greeting = fmt.Sprintf("hello, %s", name)

      if loud
        greeting = "!"
      end

      0...count.each { |i| fmt.Println(greeting) }
      fmt.Println("positional:", fs.Args())
    end
end
