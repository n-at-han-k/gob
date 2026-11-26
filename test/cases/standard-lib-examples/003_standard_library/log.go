package main

import (
	"log"      
	"log/slog" 
	"os"       
)

func runLog() {

	log.SetFlags(log.LstdFlags | log.Lshortfile)
	log.Println("classic log line")

	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	logger.Info("user signed in",
		slog.String("user", "nathan"),
		slog.Int("attempt", 1),
	)

	req := logger.With(slog.String("request_id", "abc123"))
	req.Warn("slow response", slog.Duration("elapsed", 1500))
}
