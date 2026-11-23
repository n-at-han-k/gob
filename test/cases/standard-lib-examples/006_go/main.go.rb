# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/sort — Package sort provides primitives for sorting slices and user-defined collections.
require "sort"
module Main
  # Each *.go file in this directory demonstrates one go/* subpackage —
  # the toolchain-facing packages that let Go programs read, analyse and
  # rewrite Go source. Run one demo at a time, e.g.:
  #
  # go run . ast
  #
  # or list what's available with `go run .`.
  demos = {
    "ast" => runAST,
    "build" => runBuild,
    "constraint" => runConstraint,
    "constant" => runConstant,
    "doc" => runDoc,
    "comment" => runComment,
    "format" => runFormat,
    "importer" => runImporter,
    "parser" => runParser,
    "printer" => runPrinter,
    "scanner" => runScanner,
    "token" => runToken,
    "types" => runTypes,
    "version" => runVersion
  }
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
