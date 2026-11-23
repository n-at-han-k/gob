package main

import (
	"expvar" // https://pkg.go.dev/expvar — Package expvar provides a standardized interface to public variables.
	"fmt"    // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
)

// expvar exposes named public variables. When net/http/pprof or a
// plain expvar handler is registered, they're served at /debug/vars.
// Here we just show creating and updating them.
var (
	hits    = expvar.NewInt("hits")
	lastKey = expvar.NewString("last_key")
)

func runExpvar() {
	hits.Add(1)
	hits.Add(2)
	lastKey.Set("hello")

	// expvar.Do iterates every published variable.
	expvar.Do(func(kv expvar.KeyValue) {
		fmt.Printf("%s = %s\n", kv.Key, kv.Value)
	})
}
