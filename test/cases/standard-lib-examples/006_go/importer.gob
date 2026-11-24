require "fmt"
require "go/importer"
require "log"

module Main

    # ()
    def runImporter
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
