package main

import (
	"context" // https://pkg.go.dev/context — Package context defines the Context type, which carries deadlines, cancellation signals, and other request-scoped values.
	"errors"  // https://pkg.go.dev/errors — Package errors implements functions to manipulate errors.
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"time"    // https://pkg.go.dev/time — Package time provides functionality for measuring and displaying time.
)

func work(ctx context.Context) error {
	select {
	case <-time.After(200 * time.Millisecond):
		return nil
	case <-ctx.Done():
		return ctx.Err()
	}
}

func runContext() {
	// A context with a 100ms deadline cancels itself if work overruns.
	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()

	err := work(ctx)
	if errors.Is(err, context.DeadlineExceeded) {
		fmt.Println("timed out as expected")
	}

	// WithValue attaches a request-scoped value to the context.
	type key string
	ctx2 := context.WithValue(context.Background(), key("user"), "nathan")
	fmt.Println("user:", ctx2.Value(key("user")))
}
