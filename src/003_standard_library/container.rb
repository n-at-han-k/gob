# https://pkg.go.dev/container/heap — Package heap provides heap operations for any type that implements heap.Interface.
require "container/heap"
# https://pkg.go.dev/container/list — Package list implements a doubly linked list.
require "container/list"
# https://pkg.go.dev/container/ring — Package ring implements operations on circular lists.
require "container/ring"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  # intHeap is a min-heap of ints; implements heap.Interface.
  class IntHeap
    # type intHeap []int
    def Len
      return len(this)
    end

    def Less(i, j)
      return this[i] < this[j]
    end

    def Swap(i, j)
      this[i], this[j] = this[j], this[i]
    end

    def Push(x)
      this = append(this, x)
    end

    def Pop
      old = this
      n = len(old)
      x = old[n - 1]
      this = old[...n - 1]

      return x
    end
  end

  private

    def self.runContainer
      # container/list is a doubly linked list.
      l = list.New()
      l.PushBack("b")
      l.PushFront("a")
      l.PushBack("c")
      e = l.Front()

      while e != nil
        fmt.Print(e.Value, " ")
        e = e.Next()
      end

      fmt.Println()
      # container/heap turns any heap.Interface into a priority queue.
      h = IntHeap.new(5, 1, 4, 2, 3)
      heap.Init(h)
      fmt.Print(heap.Pop(h), " ") while h.Len() > 0
      fmt.Println()
      # container/ring is a circular list where Next() past the end wraps.
      r = ring.New(5)

      0...r.Len().each do |i|
        r.Value = i
        r = r.Next()
      end

      r.Do(lambda { |v| fmt.Print(v, " ") })
      fmt.Println()
    end
end
