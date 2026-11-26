package main

import (
	"errors"
	"fmt"
	"os"
)

type notFoundError struct {
	key string
}

func (self notFoundError) Error() string {
	return fmt.Sprintf("key %q not found", self.key)
}

func lookup(k string) error {
	return &notFoundError{key: k}
}

func runErrors() {
	sentinel := errors.New("sentinel failure")
	fmt.Println(sentinel)
	wrapped := fmt.Errorf("during startup: %w", sentinel)
	fmt.Println(wrapped)
	fmt.Println("Is sentinel:", errors.Is(wrapped, sentinel))
	err := lookup("missing")
	var nf *notFoundError
	if errors.As(err, &nf) {
		fmt.Println("typed error, key:", nf.key)
	}
	_, err = os.Open("/definitely/not/there")
	fmt.Println("file missing:", errors.Is(err, os.ErrNotExist))
}
