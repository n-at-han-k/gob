# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/sort — Package sort provides primitives for sorting slices and user-defined collections.
require "sort"
module Main
  class Person
    attr_accessor :Name
    attr_accessor :Age
  end

  private

    def self.runSort
      # Sort built-in slice types with the helpers.
      nums = [5, 2, 4, 1, 3]
      sort.Ints(nums)
      fmt.Println("ints:", nums)
      # Sort a struct slice with a custom Less function.
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
      # SliceStable preserves the relative order of equal elements.
      sort.SliceStable(people, lambda { |i, j| return people[i].Age < people[j].Age })
      fmt.Println("stable:", people)
    end
end
