module Ast
  module DSL
    # def overview = tab_overview
    def AliasAccessor(name, value) = Def(name, endless: true, body: [value])
  end
end
