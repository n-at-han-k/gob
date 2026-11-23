require "database/sql"
require "fmt"
module Main
  private

    def self.runDatabase
      fmt.Println("registered drivers:", sql.Drivers())
      fmt.Println("see comments for a full CRUD flow using a driver")
    end
end
