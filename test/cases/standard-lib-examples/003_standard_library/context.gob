require "context"
require "errors"
require "fmt"
require "time"

module Main

    # (context.Context) -> error
    def work(ctx)
      select do |c|
        c << time.After(200 * time.Millisecond) { return nil }
        c << ctx.Done() { return ctx.Err() }
      end
    end

    # ()
    def runContext
      ctx, cancel =
        context.WithTimeout(context.Background(), 100 * time.Millisecond)

      defer { cancel() }
      err = work(ctx)

      if errors.Is(err, context.DeadlineExceeded)
        fmt.Println("timed out as expected")
      end

      ctx2 = context.WithValue(context.Background(), key("user"), "nathan")
      fmt.Println("user:", ctx2.Value(key("user")))
    end
end
