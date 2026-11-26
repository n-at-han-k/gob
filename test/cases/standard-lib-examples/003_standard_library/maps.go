package main

import (
	"fmt"
	"maps"
	"slices"
)

func runMaps() {
	m := map[string]int{"a": 1, "b": 2, "c": 3}

	keys := slices.Sorted(maps.Keys(m))
	fmt.Println("keys:", keys)

	cp := maps.Clone(m)
	cp["a"] = 99
	fmt.Println("orig:", m, "clone:", cp)

	fmt.Println("equal:", maps.Equal(m, map[string]int{"a": 1, "b": 2, "c": 3}))

	maps.DeleteFunc(m, func(k string, v int) bool { return v > 1 })
	fmt.Println("after delete:", m)
}
