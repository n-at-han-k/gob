require "cmp"
require "fmt"
module Main
  private

    def self.runCmp
      fmt.Println(cmp.Compare(1, 2))
      fmt.Println(cmp.Compare(3, 3))
      fmt.Println(cmp.Compare("b", "a"))
      fmt.Println(cmp.Less(1.5, 2.0))
      name = cmp.Or("", "", "fallback")
      fmt.Println(name)
    end
end
