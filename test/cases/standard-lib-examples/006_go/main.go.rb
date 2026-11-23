require "fmt"
require "os"
require "sort"
module Main
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
