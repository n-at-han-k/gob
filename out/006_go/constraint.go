package main

import (
	"fmt"
	"go/build/constraint"
	"log"
)

func runConstraint() {
	line := "//go:build linux && (amd64 || arm64)"
	expr, err := constraint.Parse(line)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("expr:", expr)
	envs := []any{map[any]any{"linux": true, "amd64": true}, map[any]any{"linux": true, "arm": true}, map[any]any{"darwin": true, "arm64": true}}
	for _, env := range envs {
		fmt.Printf("matches %v: %v\n", env, expr.Eval(func(tag any) {
			return env[tag]
		}))
	}
}
