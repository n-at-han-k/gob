package main

import (
	"container/heap" 
	"container/list" 
	"container/ring" 
	"fmt"            
)

type intHeap []int

func (h intHeap) Len() int           { return len(h) }
func (h intHeap) Less(i, j int) bool { return h[i] < h[j] }
func (h intHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *intHeap) Push(x any)        { *h = append(*h, x.(int)) }
func (h *intHeap) Pop() any          { old := *h; n := len(old); x := old[n-1]; *h = old[:n-1]; return x }

func runContainer() {

	l := list.New()
	l.PushBack("b")
	l.PushFront("a")
	l.PushBack("c")
	for e := l.Front(); e != nil; e = e.Next() {
		fmt.Print(e.Value, " ")
	}
	fmt.Println()

	h := &intHeap{5, 1, 4, 2, 3}
	heap.Init(h)
	for h.Len() > 0 {
		fmt.Print(heap.Pop(h), " ")
	}
	fmt.Println()

	r := ring.New(5)
	for i := 0; i < r.Len(); i++ {
		r.Value = i
		r = r.Next()
	}
	r.Do(func(v any) { fmt.Print(v, " ") })
	fmt.Println()
}
