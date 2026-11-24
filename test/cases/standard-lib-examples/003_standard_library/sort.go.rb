require "fmt"
require "sort"

module Main
  class Person
    attr_accessor :Name
    attr_accessor :Age
  end


    # ()
    def runSort
      nums = [5, 2, 4, 1, 3]
      sort.Ints(nums)
      fmt.Println("ints:", nums)
      people = [["C", 30], ["A", 25], ["B", 30]]

      sort.Slice(
        people,
        lambda do |i, j|
          if people[i].Age != people[j].Age
            return people[i].Age < people[j].Age
          end

          return people[i].Name < people[j].Name
        end
      )

      fmt.Println("people:", people)
      sort.SliceStable(people, lambda { |i, j| return people[i].Age < people[j].Age })
      fmt.Println("stable:", people)
    end
end
