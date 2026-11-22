# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/build — Package build gathers information about Go packages.
require "go/build"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # build asks the toolchain about a package the way `go build` would —
    # import path, source files, imports, build tags for the current arch.
    def self.runBuild
      pkg, err = build.Default.Import("fmt", "", 0)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("import path:", pkg.ImportPath)
      fmt.Println("directory:  ", pkg.Dir)
      fmt.Println("go files:   ", pkg.GoFiles)
      fmt.Println("imports:    ", pkg.Imports)
    end
end
