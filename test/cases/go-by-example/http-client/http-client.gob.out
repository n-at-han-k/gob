package main

import (
	"bufio"
	"fmt"
	"net/http"
)

func main() {
	resp, err := http.Get("https://gobyexample.com")
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()
	fmt.Println("Response status:", resp.Status)
	scanner := bufio.NewScanner(resp.Body)
	i := 0
	for scanner.Scan() && i < 5 {
		fmt.Println(scanner.Text())
		i = i + 1
	}
	if err = scanner.Err(); err != nil {
		panic(err)
	}
}
