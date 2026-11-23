package main

import (
	"log"      // https://pkg.go.dev/log — Package log implements a simple logging package.
	"log/slog" // https://pkg.go.dev/log/slog — Package slog provides structured logging with levels.
	"os"       // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
)

func runLog() {
	// Classic log package: package-level Printf, Println, Fatal.
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	log.Println("classic log line")

	// slog is Go's structured logger (Go 1.21+).
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	logger.Info("user signed in",
		slog.String("user", "nathan"),
		slog.Int("attempt", 1),
	)

	// With adds attributes to every subsequent log call.
	req := logger.With(slog.String("request_id", "abc123"))
	req.Warn("slow response", slog.Duration("elapsed", 1500))
}
