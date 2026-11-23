# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/sync — Package sync provides basic synchronization primitives such as mutual exclusion locks.
require "sync"
# https://pkg.go.dev/sync/atomic — Package atomic provides low-level atomic memory primitives useful for implementing synchronization algorithms.
require "sync/atomic"
module Main
  private

    def self.runSync
      # WaitGroup blocks until N goroutines call Done.
      wg = nil
      mu = nil
      counter = 0

      (0...100).each do |i|
        wg.Add(1)

        go do
          defer { wg.Done() }
          mu.Lock()
          counter += 1
          mu.Unlock()
        end.()
      end

      wg.Wait()
      fmt.Println("mutex counter:", counter)
      # atomic avoids locks for simple counters.
      atomicCounter = nil
      wg2 = nil

      (0...100).each do |i|
        wg2.Add(1)

        go do
          defer { wg2.Done() }
          atomicCounter.Add(1)
        end.()
      end

      wg2.Wait()
      fmt.Println("atomic counter:", atomicCounter.Load())
      # Once guarantees init code runs exactly once.
      once = nil
      (0...3).each { |i| once.Do(lambda { fmt.Println("initialised") }) }
    end
end
