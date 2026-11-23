package main

import (
	"fmt"             // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"runtime/metrics" // https://pkg.go.dev/runtime/metrics — Package metrics provides a stable interface to access implementation-defined metrics exported by the Go runtime.
)

// runtime/metrics is the modern replacement for runtime.MemStats: a
// stable, self-describing list of values you can pick individually
// instead of paying for the whole snapshot.
func runMetrics() {
	// Ask for a couple of concrete metrics.
	samples := []metrics.Sample{
		{Name: "/memory/classes/heap/objects:bytes"},
		{Name: "/sched/goroutines:goroutines"},
		{Name: "/gc/cycles/total:gc-cycles"},
	}
	metrics.Read(samples)

	for _, s := range samples {
		switch s.Value.Kind() {
		case metrics.KindUint64:
			fmt.Printf("  %-40s %d\n", s.Name, s.Value.Uint64())
		case metrics.KindFloat64:
			fmt.Printf("  %-40s %f\n", s.Name, s.Value.Float64())
		case metrics.KindBad:
			fmt.Printf("  %-40s (unsupported)\n", s.Name)
		}
	}

	// The full catalogue is discoverable at runtime.
	all := metrics.All()
	fmt.Printf("\n%d metrics available; first 5 names:\n", len(all))
	for i, d := range all {
		if i == 5 {
			break
		}
		fmt.Println("  ", d.Name)
	}
}
