require "fmt"
require "go/build/constraint"
require "log"
module Main
  private

    def self.runConstraint
      line = "//go:build linux && (amd64 || arm64)"
      expr, err = constraint.Parse(line)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("expr:", expr)

      envs = [
        { "linux" => true, "amd64" => true },
        { "linux" => true, "arm" => true },
        { "darwin" => true, "arm64" => true }
      ]

      envs.each do |_, env|
        fmt.Printf("matches %v: %v\n", env, expr.Eval(lambda { |tag| return env[tag] }))
      end
    end
end
