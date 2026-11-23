package main

import "fmt" // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.

// plugin loads shared libraries built with `go build -buildmode=plugin`.
// It's Linux/FreeBSD/macOS-only and needs a separately built .so file,
// so this file only sketches the API instead of executing it.
//
// Typical usage:
//
//	p, err := plugin.Open("./greeter.so")
//	if err != nil { log.Fatal(err) }
//
//	sym, err := p.Lookup("Greet")   // exported func or var
//	if err != nil { log.Fatal(err) }
//
//	greet := sym.(func(string) string)
//	fmt.Println(greet("world"))
//
// Build the plugin from a separate main package with:
//
//	go build -buildmode=plugin -o greeter.so greeter.go
func runPlugin() {
	fmt.Println("see comments for the plugin.Open / Lookup pattern")
}
