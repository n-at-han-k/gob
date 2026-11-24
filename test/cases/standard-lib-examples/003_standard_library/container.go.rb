require "container/heap"
require "container/list"
require "container/ring"
require "fmt"

module Main
  class IntHeap

    # () -> int
    def Len
      return len(this)
    end

    # (int, int) -> bool
    def Less(i, j)
      return this[i] < this[j]
    end

    # (int, int)
    def Swap(i, j)
      this[i], this[j] = this[j], this[i]
    end

    # (any)
    def Push(x)
      this = append(this, x)
    end

    # () -> any
    def Pop
      old = this
      n = len(old)
      x = old[n - 1]
      this = old[...n - 1]

      return x
    end
  end


    # ()
    def runContainer
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
      h = IntHeap.new(5, 1, 4, 2, 3)
      heap.Init(h)
      while h.Len() > 0
        fmt.Print(heap.Pop(h), " ")
      end
      fmt.Println()
      r = ring.New(5)

      (0...r.Len()).each do |i|
        r.Value = i
        r = r.Next()
      end

      r.Do(lambda { |v| fmt.Print(v, " ") })
      fmt.Println()
    end
end
