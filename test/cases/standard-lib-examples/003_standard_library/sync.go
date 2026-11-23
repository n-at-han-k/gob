package main

import (
	"fmt"         // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"sync"        // https://pkg.go.dev/sync — Package sync provides basic synchronization primitives such as mutual exclusion locks.
	"sync/atomic" // https://pkg.go.dev/sync/atomic — Package atomic provides low-level atomic memory primitives useful for implementing synchronization algorithms.
)

func runSync() {
	// WaitGroup blocks until N goroutines call Done.
	var wg sync.WaitGroup
	var mu sync.Mutex
	counter := 0

	for i := 0; i < 100; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			mu.Lock()
			counter++
			mu.Unlock()
		}()
	}
	wg.Wait()
	fmt.Println("mutex counter:", counter)

	// atomic avoids locks for simple counters.
	var atomicCounter atomic.Int64
	var wg2 sync.WaitGroup
	for i := 0; i < 100; i++ {
		wg2.Add(1)
		go func() { defer wg2.Done(); atomicCounter.Add(1) }()
	}
	wg2.Wait()
	fmt.Println("atomic counter:", atomicCounter.Load())

	// Once guarantees init code runs exactly once.
	var once sync.Once
	for i := 0; i < 3; i++ {
		once.Do(func() { fmt.Println("initialised") })
	}
}
