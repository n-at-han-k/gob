require "fmt"
require "os"
require "sort"

module Main
  demos = {
    "runtime" => runRuntime,
    "cgo" => runCGO,
    "coverage" => runCoverage,
    "debug" => runDebug,
    "metrics" => runMetrics,
    "pprof" => runPProf,
    "race" => runRace,
    "secret" => runSecret,
    "trace" => runTrace
  }

  # ()
  def main
    if len(os.Args) < 2
      fmt.Println("usage: go run . <package>")
      fmt.Println("available demos:")
      names = make([], 0, len(demos))
      demos.each { |k| names = append(names, k) }
      sort.Strings(names)
      names.each { |_, n| fmt.Println("  ", n) }

      return
    end

    demo, ok = demos[os.Args[1]]

    unless ok
      fmt.Println("unknown demo:", os.Args[1])
      os.Exit(1)
    end

    demo()
  end
end
