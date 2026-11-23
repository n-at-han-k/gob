# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/go/token — Package token defines constants representing the lexical tokens of the Go programming language.
require "go/token"
module Main
  private

    # token names every keyword, operator and literal category the scanner
    # can produce. It also owns FileSet — the mechanism every other go/*
    # package uses to turn a byte offset into a "file:line:col" string.
    def self.runToken
      # Predicates on token kinds.
      [token.FUNC, token.ADD, token.INT, token.IDENT].each do |_, t|
        fmt.Printf("%s\tkeyword=%v\toperator=%v\tliteral=%v\n", t, t.IsKeyword(), t.IsOperator(), t.IsLiteral())
      end

      # FileSet maps byte offsets back to human positions.
      fset = token.NewFileSet()
      f = fset.AddFile("demo.go", fset.Base(), 100)
      f.SetLinesForContent("line one\nline two\nline three".bytes)
      pos = f.Pos(10)
      fmt.Println("offset 10 is at", fset.Position(pos))
    end
end
