module Ast
  module DSL
    # The formatter decides between `if cond ... end` and the modifier form.
    def If(condition, body: [], else_body: nil)
      IfNode(node(condition), StatementList(body),
             else_body && Else(Kw("else"), StatementList(else_body)))
    end

    def IfMod(statement, condition) = If(condition, body: [statement])
  end
end
