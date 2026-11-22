# https://pkg.go.dev/database/sql — Package sql provides a generic interface around SQL (or SQL-like) databases.
require "database/sql"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # database/sql is driver-agnostic; a real program imports a driver
    # blank, e.g. _ "github.com/mattn/go-sqlite3", and calls sql.Open.
    # This example only shows the API surface — no driver is loaded.
    def self.runDatabase
      # sql.Register would add a driver; sql.Drivers lists registered ones.
      fmt.Println("registered drivers:", sql.Drivers())
      # Typical usage (won't run without a driver):
      #
      #   db, err := sql.Open("sqlite3", "file:test.db")
      #   if err != nil { log.Fatal(err) }
      #   defer db.Close()
      #
      #   _, err = db.Exec(`CREATE TABLE t (id INTEGER, name TEXT)`)
      #   _, err = db.Exec(`INSERT INTO t VALUES (?, ?)`, 1, "nathan")
      #
      #   rows, err := db.Query(`SELECT id, name FROM t`)
      #   defer rows.Close()
      #   for rows.Next() {
      #       var id int; var name string
      #       rows.Scan(&id, &name)
      #       fmt.Println(id, name)
      #   }
      fmt.Println("see comments for a full CRUD flow using a driver")
    end
end
