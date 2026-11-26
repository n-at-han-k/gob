package main

import (
	"container/heap"
	"container/list"
	"container/ring"
	"fmt"
)

type intHeapData struct {
	values []int
}

type intHeap struct {
	data *intHeapData
}

func (self intHeap) Len() int {
	data := *self.data
	values := data.values
	return len(values)
}

func (self intHeap) Less(i int, j int) bool {
	data := *self.data
	values := data.values
	return values[i] < values[j]
}

func (self intHeap) Swap(i int, j int) {
	data := *self.data
	values := data.values
	left := values[i]
	right := values[j]
	values[i] = right
	values[j] = left
}

func (self intHeap) Push(x any) {
	data := *self.data
	values := data.values
	data.values = append(values, x.(int))
}

func (self intHeap) Pop() any {
	data := *self.data
	old := data.values
	n := len(old)
	x := old[n-1]
	data.values = old[:n-1]
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
	data := &intHeapData{values: []int{5, 1, 4, 2, 3}}
	h := &intHeap{data: data}
	heap.Init(h)
	for h.Len() > 0 {
		fmt.Print(heap.Pop(h), " ")
	}
	fmt.Println()
	r := ring.New(5)
	for i := range r.Len() {
		r.Value = i
		r = r.Next()
	}
	r.Do(func(v any) {
		fmt.Print(v, " ")
	})
	fmt.Println()
}
