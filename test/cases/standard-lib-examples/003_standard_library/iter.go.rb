require "fmt"
require "iter"
require "slices"

module Main

    # (int) -> iter.Seq[int]
    def countdown(from)
      return(
        lambda do |yield_|
          i = from

          while i >= 0
            unless yield(i)
              return
            end

            i -= 1
          end
        end
      )
    end

    # ()
    def runIter
      countdown(3).each { |n| fmt.Println(n) }
      slices.All(%w[a b c]).each { |i, v| fmt.Println(i, v) }
    end
end
