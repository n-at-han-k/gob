package main

import (
	"database/sql"
	"fmt"
)

func runDatabase() {

	fmt.Println("registered drivers:", sql.Drivers())

	fmt.Println("see comments for a full CRUD flow using a driver")
}
