require "flag"
require "fmt"
require "os"

module Main

    # ()
    def runFlag
      fs = flag.NewFlagSet("demo", flag.ExitOnError)
      name = fs.String("name", "world", "who to greet")
      loud = fs.Bool("loud", false, "shout the greeting")
      count = fs.Int("count", 1, "how many times")
      fs.Parse(os.Args[2...])
      greeting = fmt.Sprintf("hello, %s", name)

      if loud
        greeting = "!"
      end

      (0...count).each { |i| fmt.Println(greeting) }
      fmt.Println("positional:", fs.Args())
    end
end
