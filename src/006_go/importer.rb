# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/importer — Package importer provides access to export data importers.
require "go/importer"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
module Main
  private

    # importer bridges go/types to the installed toolchain: given an import
    # path, hand back a *types.Package with everything the type-checker
    # needs to resolve identifiers from that package.
    def self.runImporter
      pkg, err = importer.Default().Import("fmt")

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("package:", pkg.Path())
      fmt.Println("name:   ", pkg.Name())
      fmt.Println("first 5 exported names:")

      pkg
        .Scope()
        .Names()
        .each do |i, name|
          if i == 5
            break
          end

          fmt.Println("  ", name)
        end
    end
end
