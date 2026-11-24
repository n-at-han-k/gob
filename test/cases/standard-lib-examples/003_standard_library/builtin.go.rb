require "fmt"

module Main

    # ()
    def runBuiltin
      s = make([], 0, 4)
      s = append(s, 1, 2, 3)
      fmt.Println("len/cap:", len(s), cap(s))
      dst = make([], 3)
      copy(dst, s)
      fmt.Println("copied:", dst)
      p = new(int)
      p = 42
      fmt.Println("new int:", p)
      m = { "a" => 1, "b" => 2 }
      delete(m, "a")
      fmt.Println("map:", m)
      fmt.Println("min/max:", min(3, 1, 2), max(3, 1, 2))

      defer do
        r = recover()

        if r != nil
          fmt.Println("recovered:", r)
        end
      end.()

      panic("boom")
    end
end
