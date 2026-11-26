package main

import (
	"fmt"
	"sync"
	"sync/atomic"
)

func runSync() {
	var wg sync.WaitGroup
	var mu sync.Mutex
	counter := 0
	for range 100 {
		wg.Add(1)
		go func() {
			defer wg.Done()
			mu.Lock()
			counter = counter + 1
			mu.Unlock()
		}()
	}
	wg.Wait()
	fmt.Println("mutex counter:", counter)
	var atomicCounter atomic.Int64
	var wg2 sync.WaitGroup
	for range 100 {
		wg2.Add(1)
		go func() {
			defer wg2.Done()
			atomicCounter.Add(1)
		}()
	}
	wg2.Wait()
	fmt.Println("atomic counter:", atomicCounter.Load())
	var once sync.Once
	for range 3 {
		once.Do(func() {
			fmt.Println("initialised")
		})
	}
}
