module Ast
  module DSL
    # CONDITION = <value>
    def Constant(name, value) = Assign(VarField(const_token(name)), node(value))
  end
end
