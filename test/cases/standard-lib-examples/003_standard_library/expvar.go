package main

import (
	"expvar" 
	"fmt"    
)

var hits    = expvar.NewInt("hits")
var lastKey = expvar.NewString("last_key")

func runExpvar() {
	hits.Add(1)
	hits.Add(2)
	lastKey.Set("hello")

	expvar.Do(func(kv expvar.KeyValue) {
		fmt.Printf("%s = %s\n", kv.Key, kv.Value)
	})
}
