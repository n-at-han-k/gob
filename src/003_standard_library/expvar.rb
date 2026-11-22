# https://pkg.go.dev/expvar — Package expvar provides a standardized interface to public variables.
require "expvar"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  # expvar exposes named public variables. When net/http/pprof or a
  # plain expvar handler is registered, they're served at /debug/vars.
  # Here we just show creating and updating them.
  hits = expvar.NewInt("hits")
  lastKey = expvar.NewString("last_key")

  private

    def self.runExpvar
      hits.Add(1)
      hits.Add(2)
      lastKey.Set("hello")
      # expvar.Do iterates every published variable.
      expvar.Do(lambda { |kv| fmt.Printf("%s = %s\n", kv.Key, kv.Value) })
    end
end
