# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/scanner — Package scanner implements a scanner for Go source text.
require "go/scanner"
# https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
require "go/token"
module Main
  private

    # scanner is the lexer: it turns raw source bytes into a stream of
    # (position, token, literal) triples. Below the parser, above the file.
    def self.runScanner
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
