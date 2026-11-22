package main

import (
	"errors"
	"fmt"
	"os"
)

type NotFoundError struct {
	key any
}

func (this NotFoundError) Error() {
	return fmt.Sprintf("key %q not found", this.key)
}

func lookup(k any) {
	return NotFoundError.new(map[any]any{key: k})
}

func runErrors() {
	sentinel := errors.New("sentinel failure")
	fmt.Println(sentinel)
	wrapped := fmt.Errorf("during startup: %w", sentinel)
	fmt.Println(wrapped)
	fmt.Println("Is sentinel:", errors.Is(wrapped, sentinel))
	err := lookup("missing")
	nf := nil
	if errors.As(err, nf) {
		fmt.Println("typed error, key:", nf.key)
	}
	_, err := os.Open("/definitely/not/there")
	fmt.Println("file missing:", errors.Is(err, os.ErrNotExist))
}
