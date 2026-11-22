# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/iter — Package iter provides basic definitions and operations related to iterators over sequences.
require "iter"
# https://pkg.go.dev/slices — Package slices defines various functions useful with slices of any type.
require "slices"
module Main
  private

    # countdown returns an iter.Seq[int] — a pull-style iterator you can
    # consume with for/range (Go 1.23+).
    def self.countdown(from)
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

    def self.runIter
      countdown(3).each { |n| fmt.Println(n) }
      # slices.All returns an iter.Seq2 of (index, value) pairs.
      slices.All(%w[a b c]).each { |i, v| fmt.Println(i, v) }
    end
end
