module Ast
  module DSL
    # name = value, a local variable assignment.
    def Local(name, value) = Assign(VarField(Ident(name.to_s)), node(value))
  end
end
