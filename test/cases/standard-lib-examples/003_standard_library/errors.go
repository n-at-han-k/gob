package main

import (
	"errors" // https://pkg.go.dev/errors — Package errors implements functions to manipulate errors.
	"fmt"    // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"os"     // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
)

// Custom error type carrying context.
type notFoundError struct{ key string }

func (e *notFoundError) Error() string { return fmt.Sprintf("key %q not found", e.key) }

func lookup(k string) error { return &notFoundError{key: k} }

func runErrors() {
	// errors.New builds a simple sentinel error.
	sentinel := errors.New("sentinel failure")
	fmt.Println(sentinel)

	// fmt.Errorf with %w wraps an underlying error.
	wrapped := fmt.Errorf("during startup: %w", sentinel)
	fmt.Println(wrapped)

	// errors.Is walks the wrap chain to look for a specific error.
	fmt.Println("Is sentinel:", errors.Is(wrapped, sentinel))

	// errors.As extracts a specific error type from the chain.
	err := lookup("missing")
	var nf *notFoundError
	if errors.As(err, &nf) {
		fmt.Println("typed error, key:", nf.key)
	}

	// errors.Is also works for standard errors like os.ErrNotExist.
	_, err = os.Open("/definitely/not/there")
	fmt.Println("file missing:", errors.Is(err, os.ErrNotExist))
}
