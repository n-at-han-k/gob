require "fmt"
require "strconv"
module Main
  private

    def self.runStrconv
      fmt.Println("Itoa:      ", strconv.Itoa(42))
      fmt.Println("FormatFloat:", strconv.FormatFloat(3.14, "f", 2, 64))
      fmt.Println("FormatBool:", strconv.FormatBool(true))
      n, err = strconv.Atoi("100")
      fmt.Println("Atoi:", n, err)
      f, _ = strconv.ParseFloat("2.718", 64)
      fmt.Println("ParseFloat:", f)
      fmt.Println("Quote:  ", strconv.Quote("hello \"world\""))
      unq, _ = strconv.Unquote("\"hi\\n\"")
      fmt.Printf("Unquote: %q\n", unq)
    end
end
