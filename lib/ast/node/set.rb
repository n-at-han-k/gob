module Ast
  module DSL
    # receiver.property = value, as a link. syntax_tree models it as an
    # assignment to a field rather than as a call.
    def Set(property, value)
      link { |receiver| Assign(Field(receiver || Keyword(:self), Period("."), Ident(property.to_s)), node(value)) }
    end
  end
end
