# https://pkg.go.dev/encoding/csv — Package csv reads and writes comma-separated values (CSV) files.
require "encoding/csv"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/strings — Package strings implements simple functions to manipulate UTF-8 encoded strings.
require "strings"
module Main
  private

    def self.runCSV
      # Write CSV to stdout — quoting and comma-escaping is automatic.
      w = csv.NewWriter(os.Stdout)

      w.WriteAll(
        [
          %w[name city notes],
          ["Nathan", "Wellington", "hello, world"],
          ["Ada", "London", "she said \"hi\""]
        ]
      )

      w.Flush()
      # Read it back from a string.
      input = "id,label\n1,apple\n2,orange\n3,pear\n"
      r = csv.NewReader(strings.NewReader(input))
      records, err = r.ReadAll()

      if err != nil
        log.Fatal(err)
      end

      records.each { |_, rec| fmt.Println("row:", rec) }
    end
end
