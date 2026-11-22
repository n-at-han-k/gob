module Ast
  module DSL
    # &:close, as an argument.
    def BlockPass(name) = ArgBlock(SymbolLiteral(Ident(name.to_s)))
  end
end
