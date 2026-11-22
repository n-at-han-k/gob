# https://pkg.go.dev/context — Package context defines the Context type, which carries deadlines, cancellation signals, and other request-scoped values.
require "context"
# https://pkg.go.dev/errors — Package errors implements functions to manipulate errors.
require "errors"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/time — Package time provides functionality for measuring and displaying time.
require "time"
module Main
  private

    def self.work(ctx)
      select do |c|
        c << time.After(200 * time.Millisecond) { return nil }
        c << ctx.Done() { return ctx.Err() }
      end
    end

    def self.runContext
      # A context with a 100ms deadline cancels itself if work overruns.
      ctx, cancel =
        context.WithTimeout(context.Background(), 100 * time.Millisecond)

      defer { cancel() }
      err = work(ctx)

      if errors.Is(err, context.DeadlineExceeded)
        fmt.Println("timed out as expected")
      end

      # WithValue attaches a request-scoped value to the context.
      # type key string
      ctx2 = context.WithValue(context.Background(), key("user"), "nathan")
      fmt.Println("user:", ctx2.Value(key("user")))
    end
end
