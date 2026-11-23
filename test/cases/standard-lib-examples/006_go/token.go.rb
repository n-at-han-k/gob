require "fmt"
require "go/token"
module Main
  private

    def self.runToken
      [token.FUNC, token.ADD, token.INT, token.IDENT].each do |_, t|
        fmt.Printf("%s\tkeyword=%v\toperator=%v\tliteral=%v\n", t, t.IsKeyword(), t.IsOperator(), t.IsLiteral())
      end

      fset = token.NewFileSet()
      f = fset.AddFile("demo.go", fset.Base(), 100)
      f.SetLinesForContent("line one\nline two\nline three".bytes)
      pos = f.Pos(10)
      fmt.Println("offset 10 is at", fset.Position(pos))
    end
end
