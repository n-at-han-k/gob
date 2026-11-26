package main

import (
	"context"
	"errors"
	"fmt"
	"time"
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
	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()
	err := work(ctx)
	if errors.Is(err, context.DeadlineExceeded) {
		fmt.Println("timed out as expected")
	}
	ctx2 := context.WithValue(context.Background(), "user", "nathan")
	fmt.Println("user:", ctx2.Value("user"))
}
