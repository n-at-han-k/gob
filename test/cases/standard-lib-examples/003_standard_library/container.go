package main

import (
	"container/heap" // https://pkg.go.dev/container/heap — Package heap provides heap operations for any type that implements heap.Interface.
	"container/list" // https://pkg.go.dev/container/list — Package list implements a doubly linked list.
	"container/ring" // https://pkg.go.dev/container/ring — Package ring implements operations on circular lists.
	"fmt"            // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// intHeap is a min-heap of ints; implements heap.Interface.
type intHeap []int

func (h intHeap) Len() int           { return len(h) }
func (h intHeap) Less(i, j int) bool { return h[i] < h[j] }
func (h intHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *intHeap) Push(x any)        { *h = append(*h, x.(int)) }
func (h *intHeap) Pop() any          { old := *h; n := len(old); x := old[n-1]; *h = old[:n-1]; return x }

func runContainer() {
	// container/list is a doubly linked list.
	l := list.New()
	l.PushBack("b")
	l.PushFront("a")
	l.PushBack("c")
	for e := l.Front(); e != nil; e = e.Next() {
		fmt.Print(e.Value, " ")
	}
	fmt.Println()

	// container/heap turns any heap.Interface into a priority queue.
	h := &intHeap{5, 1, 4, 2, 3}
	heap.Init(h)
	for h.Len() > 0 {
		fmt.Print(heap.Pop(h), " ")
	}
	fmt.Println()

	// container/ring is a circular list where Next() past the end wraps.
	r := ring.New(5)
	for i := 0; i < r.Len(); i++ {
		r.Value = i
		r = r.Next()
	}
	r.Do(func(v any) { fmt.Print(v, " ") })
	fmt.Println()
}
