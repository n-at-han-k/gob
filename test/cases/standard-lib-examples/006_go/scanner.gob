require "fmt"
require "go/scanner"
require "go/token"

module Main

    # ()
    def runScanner
      src = "x := 1 + 2 // trailing comment".bytes
      fset = token.NewFileSet()
      file = fset.AddFile("snippet.go", fset.Base(), len(src))
      s = nil
      s.Init(file, src, nil, scanner.ScanComments)

      loop do
        pos, tok, lit = s.Scan()

        if tok == token.EOF
          break
        end

        fmt.Printf("%s\t%s\t%q\n", fset.Position(pos), tok, lit)
      end
    end
end
