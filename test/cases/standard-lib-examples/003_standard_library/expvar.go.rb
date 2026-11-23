require "expvar"
require "fmt"
module Main
  hits = expvar.NewInt("hits")
  lastKey = expvar.NewString("last_key")

  private

    def self.runExpvar
      hits.Add(1)
      hits.Add(2)
      lastKey.Set("hello")
      expvar.Do(lambda { |kv| fmt.Printf("%s = %s\n", kv.Key, kv.Value) })
    end
end
