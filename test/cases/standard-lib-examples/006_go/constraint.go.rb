# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/build/constraint — Package constraint implements parsing and evaluation of build constraint lines.
require "go/build/constraint"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # constraint parses //go:build lines and answers "would this file be
    # included in the build for tags X?".
    def self.runConstraint
      line = "//go:build linux && (amd64 || arm64)"
      expr, err = constraint.Parse(line)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("expr:", expr)

      # Evaluate for a couple of hypothetical build environments.
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
