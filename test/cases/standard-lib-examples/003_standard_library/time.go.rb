# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/time — Package time provides functionality for measuring and displaying time.
require "time"
module Main
  private

    def self.runTime
      # Now returns the current time; Format uses the reference time
      # "Mon Jan 2 15:04:05 MST 2006" as the layout.
      now = time.Now()
      fmt.Println("iso:  ", now.Format(time.RFC3339))
      fmt.Println("ymd:  ", now.Format("2006-01-02"))
      # Parse the reverse.
      t, _ = time.Parse("2006-01-02", "2026-07-15")
      fmt.Println("parsed:", t)
      # Arithmetic and comparisons.
      tomorrow = now.Add(24 * time.Hour)
      fmt.Println("delta:", tomorrow.Sub(now))
      fmt.Println("after:", tomorrow.After(now))
      # Timer / sleep.
      start = time.Now()
      time.Sleep(50 * time.Millisecond)
      fmt.Println("slept:", time.Since(start))
    end
end
