require "fmt"
require "sync"
require "sync/atomic"
module Main
  private

    def self.runSync
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
      once = nil
      (0...3).each { |i| once.Do(lambda { fmt.Println("initialised") }) }
    end
end
