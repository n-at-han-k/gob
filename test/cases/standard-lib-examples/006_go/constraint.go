package main

import (
	"fmt"                 // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"go/build/constraint" // https://pkg.go.dev/go/build/constraint — Package constraint implements parsing and evaluation of build constraint lines.
	"log"                 // https://pkg.go.dev/log — Package log implements a simple logging package.
)

// constraint parses //go:build lines and answers "would this file be
// included in the build for tags X?".
func runConstraint() {
	line := "//go:build linux && (amd64 || arm64)"
	expr, err := constraint.Parse(line)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("expr:", expr)

	// Evaluate for a couple of hypothetical build environments.
	envs := []map[string]bool{
		{"linux": true, "amd64": true},
		{"linux": true, "arm": true},
		{"darwin": true, "arm64": true},
	}
	for _, env := range envs {
		fmt.Printf("matches %v: %v\n", env, expr.Eval(func(tag string) bool { return env[tag] }))
	}
}
