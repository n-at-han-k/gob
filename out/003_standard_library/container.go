package main

import (
	"container/heap"
	"container/list"
	"container/ring"
	"fmt"
)

type IntHeap struct {
}

func (this IntHeap) Len() {
	return len(this)
}
func (this IntHeap) Less(i any, j any) {
	return this[i] < this[j]
}
func (this IntHeap) Swap(i any, j any) {
	this[i], this[j] = []any{this[j], this[i]}
}
func (this IntHeap) Push(x any) {
	this = append(this, x)
}
func (this IntHeap) Pop() {
	old := this
	n := len(old)
	x := old[n-1]
	this = old[nil : n-1]
	return x
}

func runContainer() {
	l := list.New()
	l.PushBack("b")
	l.PushFront("a")
	l.PushBack("c")
	e := l.Front()
	for e != nil {
		fmt.Print(e.Value, " ")
		e = e.Next()
	}
	fmt.Println()
	h := IntHeap.new(5, 1, 4, 2, 3)
	heap.Init(h)
	for h.Len() > 0 {
		fmt.Print(heap.Pop(h), " ")
	}
	fmt.Println()
	r := ring.New(5)
	for i := range r.Len() {
		r.Value = (i)
		r = r.Next()
	}
	r.Do(func(v any) {
		fmt.Print(v, " ")
	})
	fmt.Println()
}
